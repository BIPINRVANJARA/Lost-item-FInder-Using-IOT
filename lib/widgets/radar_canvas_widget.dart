import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RadarCanvasWidget extends StatefulWidget {
  final double distanceMeters;
  final double bearingAngle; // in degrees
  final bool isFindingActive;
  final bool isFound;
  final Color primaryColor;
  final VoidCallback? onTargetBlipTap;

  const RadarCanvasWidget({
    super.key,
    required this.distanceMeters,
    this.bearingAngle = 45.0,
    this.isFindingActive = true,
    this.isFound = false,
    this.primaryColor = AppColors.primary,
    this.onTargetBlipTap,
  });

  @override
  State<RadarCanvasWidget> createState() => _RadarCanvasWidgetState();
}

class _RadarCanvasWidgetState extends State<RadarCanvasWidget>
    with TickerProviderStateMixin {
  late AnimationController _sweepController;
  late AnimationController _pulseController;
  late AnimationController _blipGlowController;

  @override
  void initState() {
    super.initState();
    // 360 degree continuous radar sweep rotation
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Concentric expanding sonar wave pulses
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Blip breathing glow
    _blipGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _pulseController.dispose();
    _blipGlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);

        return AnimatedBuilder(
          animation: Listenable.merge([
            _sweepController,
            _pulseController,
            _blipGlowController,
          ]),
          builder: (context, child) {
            return CustomPaint(
              size: Size(size, size),
              painter: _RadarCustomPainter(
                sweepAngle: _sweepController.value * 2 * math.pi,
                pulseProgress: _pulseController.value,
                blipGlow: _blipGlowController.value,
                distanceMeters: widget.distanceMeters,
                bearingAngle: widget.bearingAngle,
                isFindingActive: widget.isFindingActive,
                isFound: widget.isFound,
                primaryColor: widget.primaryColor,
              ),
            );
          },
        );
      },
    );
  }
}

class _RadarCustomPainter extends CustomPainter {
  final double sweepAngle;
  final double pulseProgress;
  final double blipGlow;
  final double distanceMeters;
  final double bearingAngle;
  final bool isFindingActive;
  final bool isFound;
  final Color primaryColor;

  _RadarCustomPainter({
    required this.sweepAngle,
    required this.pulseProgress,
    required this.blipGlow,
    required this.distanceMeters,
    required this.bearingAngle,
    required this.isFindingActive,
    required this.isFound,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width / 2) - 16;

    // 1. Draw radar background gradient circle
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.12),
          const Color(0xFF0F172A).withValues(alpha: 0.8),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.drawCircle(center, maxRadius, bgPaint);

    // 2. Draw outer border ring
    final borderPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, maxRadius, borderPaint);

    // 3. Draw concentric distance rings
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final ringSteps = [0.25, 0.5, 0.75, 1.0];
    for (final step in ringSteps) {
      final radius = maxRadius * step;
      canvas.drawCircle(center, radius, ringPaint);
    }

    // 4. Draw crosshair grid lines & 45-degree diagonals
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Horizontal & Vertical
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), gridPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), gridPaint);

    // 5. Draw expanding Sonar Pulse Waves if active
    if (isFindingActive && !isFound) {
      final pulseRadius1 = maxRadius * pulseProgress;
      final pulseAlpha1 = (1.0 - pulseProgress).clamp(0.0, 1.0) * 0.4;
      final pulsePaint1 = Paint()
        ..color = primaryColor.withValues(alpha: pulseAlpha1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(center, pulseRadius1, pulsePaint1);

      final secondProgress = (pulseProgress + 0.5) % 1.0;
      final pulseRadius2 = maxRadius * secondProgress;
      final pulseAlpha2 = (1.0 - secondProgress).clamp(0.0, 1.0) * 0.3;
      final pulsePaint2 = Paint()
        ..color = primaryColor.withValues(alpha: pulseAlpha2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(center, pulseRadius2, pulsePaint2);
    }

    // 6. Draw rotating Sweep Cone
    if (isFindingActive && !isFound) {
      final sweepRect = Rect.fromCircle(center: center, radius: maxRadius);
      final sweepShader = SweepGradient(
        startAngle: 0.0,
        endAngle: math.pi / 2,
        colors: [
          primaryColor.withValues(alpha: 0.0),
          primaryColor.withValues(alpha: 0.35),
        ],
        transform: GradientRotation(sweepAngle - (math.pi / 2)),
      ).createShader(sweepRect);

      final sweepPaint = Paint()
        ..shader = sweepShader
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: maxRadius)));
      canvas.drawCircle(center, maxRadius, sweepPaint);
      canvas.restore();

      // Sharp sweep leading line
      final leadingAngle = sweepAngle;
      final lineEnd = Offset(
        center.dx + maxRadius * math.cos(leadingAngle),
        center.dy + maxRadius * math.sin(leadingAngle),
      );
      final leadLinePaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.8)
        ..strokeWidth = 2.0;
      canvas.drawLine(center, lineEnd, leadLinePaint);
    }

    // 7. Calculate and draw Target Blip
    final normalizedDist = ((distanceMeters - 0.2) / 20.0).clamp(0.15, 0.9);
    final blipRadius = maxRadius * normalizedDist;
    final radBearing = (bearingAngle - 90) * (math.pi / 180);

    final blipCenter = isFound
        ? center
        : Offset(
            center.dx + blipRadius * math.cos(radBearing),
            center.dy + blipRadius * math.sin(radBearing),
          );

    // Blip Outer Glow
    final glowColor = isFound ? const Color(0xFF10B981) : (distanceMeters < 2.0 ? const Color(0xFF10B981) : primaryColor);
    final glowRadius = 14.0 + (blipGlow * 8.0);
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.4 + (blipGlow * 0.3))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(blipCenter, glowRadius, glowPaint);

    // Blip Inner Solid Core
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(blipCenter, 7.0, corePaint);

    final coreRingPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(blipCenter, 7.0, coreRingPaint);

    // 8. Draw Center User Beacon Dot
    final userDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5.0, userDotPaint);

    final userRingPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, 9.0, userRingPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarCustomPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.blipGlow != blipGlow ||
        oldDelegate.distanceMeters != distanceMeters ||
        oldDelegate.isFound != isFound;
  }
}

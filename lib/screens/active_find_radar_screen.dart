import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tracked_item.dart';
import '../models/item_status.dart';
import '../providers/item_provider.dart';
import '../services/firebase_iot_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import '../widgets/radar_canvas_widget.dart';
import '../widgets/glass_container.dart';
import '../widgets/status_badge.dart';
import '../widgets/battery_indicator.dart';
import 'iot_hardware_hub_screen.dart';

class ActiveFindRadarScreen extends StatefulWidget {
  final TrackedItem item;

  const ActiveFindRadarScreen({
    super.key,
    required this.item,
  });

  @override
  State<ActiveFindRadarScreen> createState() => _ActiveFindRadarScreenState();
}

class _ActiveFindRadarScreenState extends State<ActiveFindRadarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _strobeController;

  @override
  void initState() {
    super.initState();
    _strobeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);

    // Initialize finding session & dispatch real IoT Firebase command to ESP32
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().startFinding(widget.item);
      context.read<FirebaseIotService>().sendFindCommand(active: true);
    });
  }

  @override
  void dispose() {
    _strobeController.dispose();
    super.dispose();
  }

  String _getProximityAdvice(double distance) {
    if (distance <= 0.5) {
      return 'Right Here! Follow the 433MHz buzzer sound.';
    } else if (distance <= 2.0) {
      return 'Very Close! 433MHz RF Remote triggered.';
    } else if (distance <= 6.0) {
      return 'Getting Closer — RF remote button active.';
    } else if (distance <= 15.0) {
      return 'Nearby — Walk towards the audible buzzer.';
    } else {
      return 'Triggering ESP32 433MHz RF remote transmitter.';
    }
  }

  Color _getProximityColor(double distance) {
    if (distance <= 1.0) return AppColors.primary;
    if (distance <= 5.0) return AppColors.statusNearby;
    if (distance <= 12.0) return AppColors.secondary;
    return AppColors.statusWarning;
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();
    final iotService = context.watch<FirebaseIotService>();
    final dist = itemProvider.simulatedDistance;
    final proximityColor = _getProximityColor(dist);
    final isFound = itemProvider.isItemFound;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Simulated Flashlight Strobe Overlay
          if (itemProvider.isFlashlightOn)
            AnimatedBuilder(
              animation: _strobeController,
              builder: (context, child) {
                return Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.white.withValues(
                        alpha: 0.15 + (_strobeController.value * 0.25),
                      ),
                    ),
                  ),
                );
              },
            ),

          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Row(
                    children: [
                      // Back / Close Button
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () {
                          itemProvider.stopFinding();
                          iotService.sendFindCommand(active: false);
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 4),

                      // Item Title & Category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.item.name,
                              style: AppTypography.title(context, isDark: true).copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '433 MHz RF Tracker (${widget.item.category.displayName})',
                              style: AppTypography.bodySmall(context, isDark: true).copyWith(
                                color: AppColors.textSecondaryDark,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Hardware Hub Quick Link
                      IconButton(
                        icon: const Icon(Icons.settings_input_antenna_rounded, color: AppColors.primary, size: 20),
                        tooltip: 'IoT Hardware Hub',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const IotHardwareHubScreen()),
                          );
                        },
                      ),

                      // Status & Battery
                      StatusBadge(
                        status: isFound ? ItemStatus.connected : widget.item.status,
                        fontSize: 9,
                      ),
                      const SizedBox(width: 6),
                      BatteryIndicator(batteryLevel: widget.item.batteryLevel),
                    ],
                  ),
                ),

                // Proximity Distance & IoT Status Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: GlassContainer(
                    backgroundColor: AppColors.surfaceDark.withValues(alpha: 0.8),
                    borderColor: proximityColor.withValues(alpha: 0.4),
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      Formatters.formatDistance(dist),
                                      style: AppTypography.displayMedium(context, isDark: true).copyWith(
                                        color: proximityColor,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    Formatters.formatRssi(itemProvider.simulatedRssi),
                                    style: AppTypography.monoLabel(
                                      fontSize: 11,
                                      color: AppColors.textMutedDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isFound ? 'Item Located!' : _getProximityAdvice(dist),
                                style: AppTypography.bodySmall(context, isDark: true).copyWith(
                                  color: isFound ? AppColors.primary : AppColors.textSecondaryDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'IoT: ${iotService.lastStatusMessage}',
                                style: AppTypography.monoLabel(
                                  fontSize: 9,
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Animated Pulse Indicator
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: proximityColor.withValues(alpha: 0.15),
                            border: Border.all(
                              color: proximityColor.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            isFound
                                ? Icons.check_circle_rounded
                                : Icons.radar_rounded,
                            color: proximityColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Radar View (Flexible & Scaled with FittedBox)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: 280,
                          height: 280,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              RadarCanvasWidget(
                                distanceMeters: dist,
                                bearingAngle: itemProvider.radarBearingAngle,
                                isFindingActive: itemProvider.isFindingActive,
                                isFound: isFound,
                                primaryColor: proximityColor,
                              ),

                              if (isFound)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.5),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 32),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Found It!',
                                        style: AppTypography.title(context, isDark: true).copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Interactive Proximity Simulation Stepper
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Simulate Walking Distance:',
                          style: AppTypography.monoLabel(
                            fontSize: 10,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.filledTonal(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.remove_rounded, size: 14),
                            onPressed: () {
                              itemProvider.setSimulatedDistance(dist - 1.0);
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceDarkElevated,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.add_rounded, size: 14),
                            onPressed: () {
                              itemProvider.setSimulatedDistance(dist + 1.0);
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceDarkElevated,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Controls Bottom Container (Responsive Padding)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceDarkCard,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(
                      top: BorderSide(color: AppColors.borderDark, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Re-trigger 433 MHz RF Remote & Flashlight Buttons
                      Row(
                        children: [
                          // Send 433 MHz RF Remote Burst Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                iotService.sendFindCommand(active: true);
                              },
                              icon: const Icon(
                                Icons.settings_input_antenna_rounded,
                                size: 16,
                              ),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('Trigger RF Remote'),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Flashlight Strobe Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => itemProvider.toggleFlashlight(),
                              icon: Icon(
                                itemProvider.isFlashlightOn
                                    ? Icons.flashlight_on_rounded
                                    : Icons.flashlight_off_rounded,
                                size: 16,
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(itemProvider.isFlashlightOn ? 'Light Off' : 'Light On'),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: itemProvider.isFlashlightOn
                                    ? const Color(0xFFF59E0B)
                                    : AppColors.surfaceDarkElevated,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // "I Found It!" & "Stop Alert" Buttons
                      Row(
                        children: [
                          if (!isFound)
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  itemProvider.markItemFound();
                                  iotService.sendFindCommand(active: false);
                                },
                                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('I Found It!'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 3,
                                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          if (!isFound) const SizedBox(width: 10),

                          // Stop Alert Button
                          Expanded(
                            flex: isFound ? 1 : 2,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                itemProvider.stopFinding();
                                iotService.sendFindCommand(active: false);
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.stop_circle_outlined, size: 16),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(isFound ? 'Done' : 'Stop Alert'),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isFound ? Colors.white : AppColors.statusDisconnected,
                                side: BorderSide(
                                  color: isFound ? AppColors.primary : AppColors.statusDisconnected.withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

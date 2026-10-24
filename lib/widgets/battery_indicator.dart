import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class BatteryIndicator extends StatelessWidget {
  final int batteryLevel; // 0 - 100
  final bool showPercentage;

  const BatteryIndicator({
    super.key,
    required this.batteryLevel,
    this.showPercentage = true,
  });

  Color get _batteryColor {
    if (batteryLevel > 50) return AppColors.primary;
    if (batteryLevel > 20) return AppColors.statusWarning;
    return AppColors.statusDisconnected;
  }

  IconData get _batteryIcon {
    if (batteryLevel >= 90) return Icons.battery_full_rounded;
    if (batteryLevel >= 70) return Icons.battery_6_bar_rounded;
    if (batteryLevel >= 50) return Icons.battery_5_bar_rounded;
    if (batteryLevel >= 30) return Icons.battery_3_bar_rounded;
    if (batteryLevel >= 15) return Icons.battery_2_bar_rounded;
    return Icons.battery_alert_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _batteryIcon,
          size: 16,
          color: _batteryColor,
        ),
        if (showPercentage) ...[
          const SizedBox(width: 4),
          Text(
            '$batteryLevel%',
            style: AppTypography.monoLabel(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _batteryColor,
            ),
          ),
        ],
      ],
    );
  }
}

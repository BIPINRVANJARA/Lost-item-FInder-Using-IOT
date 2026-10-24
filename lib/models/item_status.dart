import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ItemStatus {
  connected,
  nearby,
  disconnected,
  unknown;

  String get displayName {
    switch (this) {
      case ItemStatus.connected:
        return 'Connected';
      case ItemStatus.nearby:
        return 'Nearby';
      case ItemStatus.disconnected:
        return 'Disconnected';
      case ItemStatus.unknown:
        return 'Unknown';
    }
  }

  String get description {
    switch (this) {
      case ItemStatus.connected:
        return 'The item is currently reachable.';
      case ItemStatus.nearby:
        return 'The item appears to be within usable range.';
      case ItemStatus.disconnected:
        return 'Cannot currently communicate with this item.';
      case ItemStatus.unknown:
        return 'Insufficient information to determine current state.';
    }
  }

  Color get color {
    switch (this) {
      case ItemStatus.connected:
        return AppColors.statusConnected;
      case ItemStatus.nearby:
        return AppColors.statusNearby;
      case ItemStatus.disconnected:
        return AppColors.statusDisconnected;
      case ItemStatus.unknown:
        return AppColors.statusUnknown;
    }
  }

  IconData get icon {
    switch (this) {
      case ItemStatus.connected:
        return Icons.bluetooth_connected_rounded;
      case ItemStatus.nearby:
        return Icons.radar_rounded;
      case ItemStatus.disconnected:
        return Icons.bluetooth_disabled_rounded;
      case ItemStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }
}

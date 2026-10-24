import 'package:flutter/material.dart';

enum NotificationType {
  disconnected,
  reconnected,
  lowBattery,
  itemFound,
  leftBehind,
  detectedNearby,
  findingStarted,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final String? itemId;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.itemId,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.disconnected:
        return Icons.link_off_rounded;
      case NotificationType.reconnected:
        return Icons.link_rounded;
      case NotificationType.lowBattery:
        return Icons.battery_alert_rounded;
      case NotificationType.itemFound:
        return Icons.check_circle_rounded;
      case NotificationType.leftBehind:
        return Icons.warning_amber_rounded;
      case NotificationType.detectedNearby:
        return Icons.radar_rounded;
      case NotificationType.findingStarted:
        return Icons.campaign_rounded;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.disconnected:
        return const Color(0xFFF43F5E);
      case NotificationType.reconnected:
        return const Color(0xFF10B981);
      case NotificationType.lowBattery:
        return const Color(0xFFF59E0B);
      case NotificationType.itemFound:
        return const Color(0xFF10B981);
      case NotificationType.leftBehind:
        return const Color(0xFFEF4444);
      case NotificationType.detectedNearby:
        return const Color(0xFF38BDF8);
      case NotificationType.findingStarted:
        return const Color(0xFF8B5CF6);
    }
  }
}

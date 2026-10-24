import 'package:flutter/material.dart';
import '../models/app_notification.dart';

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider();

  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? itemId,
  }) {
    final notif = AppNotification(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      itemId: itemId,
      isRead: false,
    );
    _notifications.insert(0, notif);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (final notif in _notifications) {
      notif.isRead = true;
    }
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}

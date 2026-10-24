import '../models/tracked_item.dart';
import '../models/app_notification.dart';

class DummyData {
  /// App starts clean with zero hardcoded dummy data
  static List<TrackedItem> get initialItems => [];

  /// Zero fake notifications
  static List<AppNotification> get initialNotifications => [];
}

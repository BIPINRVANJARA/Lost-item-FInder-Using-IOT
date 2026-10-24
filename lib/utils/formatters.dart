import 'package:intl/intl.dart';

class Formatters {
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 45) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins min${mins > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hr${hours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days day${days > 1 ? 's' : ''} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }

  static String formatFullDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final isToday = now.year == dateTime.year && now.month == dateTime.month && now.day == dateTime.day;
    final timeStr = DateFormat('h:mm a').format(dateTime);
    
    if (isToday) {
      return 'Today, $timeStr';
    } else {
      final dateStr = DateFormat('MMM d').format(dateTime);
      return '$dateStr, $timeStr';
    }
  }

  static String formatDistance(double meters) {
    if (meters < 1.0) {
      final cm = (meters * 100).round();
      return '$cm cm';
    } else if (meters < 1000) {
      return '${meters.toStringAsFixed(1)} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(2)} km';
    }
  }

  static String formatRssi(int rssi) {
    return '$rssi dBm';
  }
}

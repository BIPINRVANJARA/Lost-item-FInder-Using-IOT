import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import '../widgets/glass_container.dart';
import 'item_details_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifs = notifProvider.notifications;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifs.isNotEmpty)
            TextButton(
              onPressed: () => notifProvider.markAllAsRead(),
              child: const Text('Read All'),
            ),
          if (notifs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all_rounded),
              onPressed: () => notifProvider.clearAll(),
            ),
        ],
      ),
      body: notifs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Notifications',
                    style: AppTypography.title(context, isDark: isDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You are all caught up! Items are secure.',
                    style: AppTypography.bodySmall(context, isDark: isDark),
                  ),
                ],
              ),
            )
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: notifs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifs[index];
                return GlassContainer(
                  onTap: () {
                    notifProvider.markAsRead(notif.id);
                    if (notif.itemId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemDetailsScreen(itemId: notif.itemId!),
                        ),
                      );
                    }
                  },
                  backgroundColor: !notif.isRead
                      ? (isDark
                          ? AppColors.surfaceDarkElevated.withValues(alpha: 0.9)
                          : AppColors.surfaceLightElevated)
                      : null,
                  padding: const EdgeInsets.all(16),
                  borderRadius: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: notif.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(notif.icon, color: notif.color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notif.title,
                                    style: AppTypography.title(context, isDark: isDark).copyWith(
                                      fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                if (!notif.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.message,
                              style: AppTypography.bodySmall(context, isDark: isDark).copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              Formatters.timeAgo(notif.timestamp),
                              style: AppTypography.monoLabel(
                                fontSize: 10,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

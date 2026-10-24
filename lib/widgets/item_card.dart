import 'package:flutter/material.dart';
import '../models/tracked_item.dart';
import '../models/item_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import 'glass_container.dart';
import 'status_badge.dart';
import 'battery_indicator.dart';

class ItemCard extends StatelessWidget {
  final TrackedItem item;
  final VoidCallback onTap;
  final VoidCallback onFind;
  final VoidCallback onToggleFavorite;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onFind,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = item.category.color;

    return GlassContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category Icon, Name & Category, Favorite Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  item.category.icon,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Item Title & Category Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTypography.title(context, isDark: isDark).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.category.displayName,
                      style: AppTypography.bodySmall(context, isDark: isDark),
                    ),
                  ],
                ),
              ),

              // Favorite Heart Toggle
              IconButton(
                icon: Icon(
                  item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: item.isFavorite ? const Color(0xFFEF4444) : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  size: 20,
                ),
                onPressed: onToggleFavorite,
                visualDensity: VisualDensity.compact,
                splashRadius: 20,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Middle Row: Status & Battery
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(status: item.status),
              BatteryIndicator(batteryLevel: item.batteryLevel),
            ],
          ),

          const SizedBox(height: 12),

          // Divider
          Container(
            height: 1,
            color: isDark ? AppColors.borderDark.withValues(alpha: 0.6) : AppColors.borderLight,
          ),

          const SizedBox(height: 12),

          // Bottom Row: Last Seen / Distance & "Find" Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Location / Distance indicator
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.lastSeenLocation,
                            style: AppTypography.bodySmall(context, isDark: isDark).copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.status == ItemStatus.connected || item.status == ItemStatus.nearby
                          ? 'Approx. ${Formatters.formatDistance(item.distanceMeters)} away'
                          : 'Last seen ${Formatters.timeAgo(item.lastSeenTime)}',
                      style: AppTypography.monoLabel(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Find Button
              ElevatedButton.icon(
                onPressed: onFind,
                icon: const Icon(Icons.radar_rounded, size: 16),
                label: const Text('Find'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.status == ItemStatus.disconnected
                      ? (isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated)
                      : AppColors.primary,
                  foregroundColor: item.status == ItemStatus.disconnected
                      ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: item.status == ItemStatus.disconnected
                        ? BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)
                        : BorderSide.none,
                  ),
                  elevation: item.status == ItemStatus.disconnected ? 0 : 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

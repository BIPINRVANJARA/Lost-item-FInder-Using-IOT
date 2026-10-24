import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tracked_item.dart';
import '../providers/item_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import '../widgets/glass_container.dart';
import '../widgets/status_badge.dart';
import '../widgets/battery_indicator.dart';
import 'active_find_radar_screen.dart';
import 'add_edit_item_screen.dart';

class ItemDetailsScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailsScreen({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final itemIndex = itemProvider.items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Item not found')),
      );
    }
    final item = itemProvider.items[itemIndex];
    final categoryColor = item.category.color;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: Icon(
              item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: item.isFavorite ? const Color(0xFFEF4444) : null,
            ),
            onPressed: () => itemProvider.toggleFavorite(item.id),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditItemScreen(itemToEdit: item),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusDisconnected),
            onPressed: () => _showDeleteConfirmation(context, itemProvider, item),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card with Icon & Status
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: 28,
              child: Column(
                children: [
                  Row(
                    children: [
                      // Large Icon Container
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          item.category.icon,
                          color: categoryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title & Category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: AppTypography.headline(context, isDark: isDark).copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.category.displayName,
                              style: AppTypography.bodyMedium(context, isDark: isDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Status & Battery Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge(status: item.status, fontSize: 12),
                      BatteryIndicator(batteryLevel: item.batteryLevel, showPercentage: true),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Primary "Find Item" Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ActiveFindRadarScreen(item: item),
                          ),
                        );
                      },
                      icon: const Icon(Icons.radar_rounded, size: 20),
                      label: const Text('Find Item (Active Radar)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Live Telemetry Grid
            Text(
              'DEVICE TELEMETRY',
              style: AppTypography.monoLabel(
                fontSize: 11,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(14),
                    borderRadius: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.wifi_tethering_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(height: 8),
                        Text(
                          Formatters.formatRssi(item.rssi),
                          style: AppTypography.monoLabel(fontSize: 16, color: AppColors.primary),
                        ),
                        Text(
                          'Signal Strength',
                          style: AppTypography.bodySmall(context, isDark: isDark),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(14),
                    borderRadius: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.straighten_rounded, color: AppColors.secondary, size: 20),
                        const SizedBox(height: 8),
                        Text(
                          Formatters.formatDistance(item.distanceMeters),
                          style: AppTypography.monoLabel(fontSize: 16, color: AppColors.secondary),
                        ),
                        Text(
                          'Approx. Distance',
                          style: AppTypography.bodySmall(context, isDark: isDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Last Known Location Card
            Text(
              'LAST KNOWN LOCATION',
              style: AppTypography.monoLabel(
                fontSize: 11,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 10),

            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.lastSeenLocation,
                              style: AppTypography.title(context, isDark: isDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              Formatters.formatFullDateTime(item.lastSeenTime),
                              style: AppTypography.monoLabel(
                                fontSize: 11,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Stylized Floorplan / GPS Mini Map Mockup
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Grid lines
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _MiniMapGridPainter(isDark: isDark),
                          ),
                        ),
                        // Pin
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 18),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.name,
                                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
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

            const SizedBox(height: 20),

            // Smart Protection & Alerts
            Text(
              'SMART SETTINGS & PROTECTION',
              style: AppTypography.monoLabel(
                fontSize: 11,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 10),

            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 20,
              child: Column(
                children: [
                  // Separation Alert Toggle
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Separation Alert',
                      style: AppTypography.title(context, isDark: isDark),
                    ),
                    subtitle: Text(
                      'Notify if item gets separated from device',
                      style: AppTypography.bodySmall(context, isDark: isDark),
                    ),
                    value: item.separationAlertEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (_) => itemProvider.toggleSeparationAlert(item.id),
                  ),
                  const Divider(),

                  // Lost Mode Toggle
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Lost Mode',
                      style: AppTypography.title(context, isDark: isDark),
                    ),
                    subtitle: Text(
                      'Broadcast Bluetooth distress signal to find network',
                      style: AppTypography.bodySmall(context, isDark: isDark),
                    ),
                    value: item.isLostModeActive,
                    activeThumbColor: AppColors.statusDisconnected,
                    onChanged: (_) => itemProvider.toggleLostMode(item.id),
                  ),
                  const Divider(),

                  // Ringtone Sound
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Chime Sound',
                      style: AppTypography.title(context, isDark: isDark),
                    ),
                    subtitle: Text(
                      item.ringtone,
                      style: AppTypography.monoLabel(
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      _showRingtonePicker(context, itemProvider, item);
                    },
                  ),
                ],
              ),
            ),

            if (item.notes.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'NOTES',
                style: AppTypography.monoLabel(
                  fontSize: 11,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
              const SizedBox(height: 10),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 20,
                child: Text(
                  item.notes,
                  style: AppTypography.bodyMedium(context, isDark: isDark),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ItemProvider provider, TrackedItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Tracked Item?'),
        content: Text('Are you sure you want to remove "${item.name}" from your lost finder dashboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteItem(item.id);
              Navigator.pop(ctx); // Dialog
              Navigator.pop(context); // Screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDisconnected,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showRingtonePicker(BuildContext context, ItemProvider provider, TrackedItem item) {
    final ringtones = ['Sonar Pulse', 'High Pitch Chime', 'Echo Melody', 'Rapid Pulse', 'Classic Beeper'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Chime Tone', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...ringtones.map((tone) => ListTile(
                  title: Text(tone),
                  trailing: item.ringtone == tone ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () {
                    provider.updateItem(item.copyWith(ringtone: tone));
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _MiniMapGridPainter extends CustomPainter {
  final bool isDark;
  _MiniMapGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

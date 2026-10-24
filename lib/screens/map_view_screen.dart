import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../models/tracked_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_container.dart';
import '../widgets/status_badge.dart';
import '../widgets/battery_indicator.dart';
import 'active_find_radar_screen.dart';
import 'item_details_screen.dart';
import 'add_edit_item_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  TrackedItem? _selectedItem;
  bool _isFloorplanMode = true;

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();
    final items = itemProvider.items;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Interactive Custom Map / Floorplan Canvas
          Positioned.fill(
            child: _InteractiveMapBackground(
              items: items,
              selectedItem: _selectedItem,
              isFloorplanMode: _isFloorplanMode,
              onSelectItem: (item) {
                setState(() {
                  _selectedItem = item;
                });
              },
            ),
          ),

          // Top Header Floating Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title Pill
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    borderRadius: 20,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map_rounded, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Radar Map',
                          style: AppTypography.title(context, isDark: isDark).copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // Mode Switcher (Floorplan / Map)
                  GlassContainer(
                    padding: const EdgeInsets.all(3),
                    borderRadius: 20,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildModeTab('Indoor', _isFloorplanMode, () {
                          setState(() => _isFloorplanMode = true);
                        }),
                        _buildModeTab('GPS Map', !_isFloorplanMode, () {
                          setState(() => _isFloorplanMode = false);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Empty state banner if no items
          if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_searching_rounded, size: 36, color: AppColors.primary),
                      const SizedBox(height: 12),
                      Text(
                        'No Items on Radar',
                        style: AppTypography.title(context, isDark: isDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add a tracked item to see its live position on the map.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall(context, isDark: isDark),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddEditItemScreen()),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Item'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Selected Item Floating Card
          if (_selectedItem != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: GlassContainer(
                padding: const EdgeInsets.all(14),
                borderRadius: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedItem!.category.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _selectedItem!.category.icon,
                            color: _selectedItem!.category.color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedItem!.name,
                                style: AppTypography.title(context, isDark: isDark).copyWith(fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _selectedItem!.lastSeenLocation,
                                style: AppTypography.bodySmall(context, isDark: isDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () => setState(() => _selectedItem = null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatusBadge(status: _selectedItem!.status, fontSize: 10),
                        BatteryIndicator(batteryLevel: _selectedItem!.batteryLevel),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ItemDetailsScreen(itemId: _selectedItem!.id),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Details'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ActiveFindRadarScreen(item: _selectedItem!),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.radar_rounded, size: 16),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Find Item'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeTab(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }
}

class _InteractiveMapBackground extends StatelessWidget {
  final List<TrackedItem> items;
  final TrackedItem? selectedItem;
  final bool isFloorplanMode;
  final Function(TrackedItem) onSelectItem;

  const _InteractiveMapBackground({
    required this.items,
    required this.selectedItem,
    required this.isFloorplanMode,
    required this.onSelectItem,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Spread item pins across map canvas
        final pinPositions = [
          Offset(width * 0.48, height * 0.42),
          Offset(width * 0.72, height * 0.35),
          Offset(width * 0.25, height * 0.65),
          Offset(width * 0.42, height * 0.52),
          Offset(width * 0.80, height * 0.58),
          Offset(width * 0.20, height * 0.30),
        ];

        return Stack(
          children: [
            // Background Grid & Architectural Floorplan lines
            CustomPaint(
              size: Size(width, height),
              painter: _MapCanvasPainter(
                isDark: isDark,
                isFloorplan: isFloorplanMode,
              ),
            ),

            // User Self Location Marker (Blue Pulse)
            Positioned(
              left: width * 0.5 - 20,
              top: height * 0.48 - 20,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.my_location_rounded, color: Color(0xFF38BDF8), size: 20),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('You', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ],
              ),
            ),

            // Item Markers
            for (int i = 0; i < items.length; i++) ...[
              Builder(
                builder: (context) {
                  final item = items[i];
                  final pos = pinPositions[i % pinPositions.length];
                  final isSelected = selectedItem?.id == item.id;
                  final catColor = item.category.color;

                  return Positioned(
                    left: pos.dx - 24,
                    top: pos.dy - 24,
                    child: GestureDetector(
                      onTap: () => onSelectItem(item),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: isSelected ? 44 : 36,
                            height: isSelected ? 44 : 36,
                            decoration: BoxDecoration(
                              color: catColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: isSelected ? 2.5 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: catColor.withValues(alpha: isSelected ? 0.6 : 0.35),
                                  blurRadius: isSelected ? 16 : 8,
                                  spreadRadius: isSelected ? 2 : 0,
                                ),
                              ],
                            ),
                            child: Icon(
                              item.category.icon,
                              color: Colors.white,
                              size: isSelected ? 22 : 18,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  final bool isDark;
  final bool isFloorplan;

  _MapCanvasPainter({required this.isDark, required this.isFloorplan});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final linePaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    // Background Grid
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    if (isFloorplan) {
      final wallPaint = Paint()
        ..color = (isDark ? AppColors.borderDark : AppColors.borderLight)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      // Outer room boundary
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.6),
          const Radius.circular(20),
        ),
        wallPaint,
      );

      // Room partitions
      canvas.drawLine(
        Offset(size.width * 0.5, size.height * 0.2),
        Offset(size.width * 0.5, size.height * 0.5),
        wallPaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.1, size.height * 0.55),
        Offset(size.width * 0.6, size.height * 0.55),
        wallPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

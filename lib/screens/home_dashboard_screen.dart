import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../providers/notification_provider.dart';
import '../services/firebase_iot_service.dart';
import '../models/item_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/metric_stat_card.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/item_card.dart';
import '../widgets/glass_container.dart';
import 'item_details_screen.dart';
import 'active_find_radar_screen.dart';
import 'add_edit_item_screen.dart';
import 'notifications_screen.dart';
import 'iot_hardware_hub_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final iotService = context.watch<FirebaseIotService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = itemProvider.filteredItems;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar & Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Lost Finder',
                            style: AppTypography.displayMedium(context, isDark: isDark).copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Hotspot: vivoy200 (Ready)',
                                style: AppTypography.monoLabel(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // IoT Hardware Hub & Notification & Add
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings_input_antenna_rounded, color: AppColors.primary),
                          tooltip: 'ESP32 Settings',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const IotHardwareHubScreen()),
                            );
                          },
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                                );
                              },
                            ),
                            if (notifProvider.unreadCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.statusDisconnected,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${notifProvider.unreadCount}',
                                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 2),
                        IconButton.filled(
                          icon: const Icon(Icons.add_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddEditItemScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 🚀 1-TAP BIG BUZZER TRIGGER HERO BUTTON CARD
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GlassContainer(
                  padding: const EdgeInsets.all(18),
                  borderRadius: 24,
                  backgroundColor: isDark
                      ? AppColors.surfaceDarkCard.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.9),
                  borderColor: AppColors.primary.withValues(alpha: 0.3),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.wifi_tethering_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'ESP32 433 MHz TRIGGER',
                                style: AppTypography.monoLabel(fontSize: 11, color: AppColors.primary),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'DOUBLE BEEP',
                              style: AppTypography.monoLabel(fontSize: 9, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Large Pressable Action Button
                      GestureDetector(
                        onTap: iotService.isSending
                            ? null
                            : () {
                                iotService.sendFindCommand(active: true);
                              },
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(
                                      alpha: 0.35 + (_pulseController.value * 0.25),
                                    ),
                                    blurRadius: 16 + (_pulseController.value * 10),
                                    spreadRadius: 1 + (_pulseController.value * 3),
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (iotService.isSending)
                                    const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.campaign_rounded,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        iotService.isSending ? 'BEEPING BUZZER...' : 'BEEP BUZZER NOW',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Tap to pulse 433 MHz RF remote (Beep-Beep)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Status: ${iotService.lastStatusMessage}',
                        style: AppTypography.monoLabel(
                          fontSize: 10,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => itemProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search items, tags, locations...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              itemProvider.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Metric Operational Overview Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: MetricStatCard(
                        title: 'Connected',
                        value: '${itemProvider.connectedCount}',
                        subtitle: 'Online',
                        icon: Icons.bluetooth_connected_rounded,
                        accentColor: AppColors.primary,
                        onTap: () {
                          itemProvider.setSelectedStatus(
                            itemProvider.selectedStatus == ItemStatus.connected ? null : ItemStatus.connected,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MetricStatCard(
                        title: 'Nearby',
                        value: '${itemProvider.nearbyCount}',
                        subtitle: 'In Range',
                        icon: Icons.radar_rounded,
                        accentColor: AppColors.statusNearby,
                        onTap: () {
                          itemProvider.setSelectedStatus(
                            itemProvider.selectedStatus == ItemStatus.nearby ? null : ItemStatus.nearby,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MetricStatCard(
                        title: 'RF Trigger',
                        value: '433MHz',
                        subtitle: 'ESP32 GPIO 25',
                        icon: Icons.settings_input_antenna_rounded,
                        accentColor: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category Filter Pills Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: CategoryFilterBar(
                  selectedCategory: itemProvider.selectedCategory,
                  onSelectCategory: (category) => itemProvider.setSelectedCategory(category),
                ),
              ),
            ),

            // Section Heading
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MY TRACKED BELONGINGS',
                      style: AppTypography.monoLabel(
                        fontSize: 11,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                    Text(
                      '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                      style: AppTypography.monoLabel(
                        fontSize: 11,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Items List or Clean Empty State
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(22),
                      borderRadius: 26,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.radar_rounded,
                                size: 32,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            itemProvider.totalCount == 0
                                ? 'No Tracked Items Yet'
                                : 'No Matching Items',
                            style: AppTypography.headline(context, isDark: isDark).copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'You can use the big green button above to trigger your 433 MHz buzzer anytime, or add custom tracked tags below.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall(context, isDark: isDark).copyWith(
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddEditItemScreen()),
                                );
                              },
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add Tracked Item'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ItemCard(
                          item: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ItemDetailsScreen(itemId: item.id),
                              ),
                            );
                          },
                          onFind: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActiveFindRadarScreen(item: item),
                              ),
                            );
                          },
                          onToggleFavorite: () => itemProvider.toggleFavorite(item.id),
                        ),
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

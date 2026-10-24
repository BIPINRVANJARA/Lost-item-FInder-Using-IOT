import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../theme/app_colors.dart';
import 'home_dashboard_screen.dart';
import 'map_view_screen.dart';
import 'notifications_screen.dart';
import 'settings_profile_screen.dart';
import 'add_edit_item_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    MapViewScreen(),
    NotificationsScreen(),
    SettingsProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditItemScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomAppBar(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            height: 64,
            color: Colors.transparent,
            elevation: 0,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Dashboard / Items
                _buildNavItem(
                  index: 0,
                  icon: Icons.dashboard_rounded,
                  label: 'Items',
                  isSelected: _currentIndex == 0,
                ),

                // Map Radar
                _buildNavItem(
                  index: 1,
                  icon: Icons.radar_rounded,
                  label: 'Map Radar',
                  isSelected: _currentIndex == 1,
                ),

                const SizedBox(width: 48), // Gap for FloatingActionButton

                // Notifications with Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildNavItem(
                      index: 2,
                      icon: Icons.notifications_rounded,
                      label: 'Alerts',
                      isSelected: _currentIndex == 2,
                    ),
                    if (notifProvider.unreadCount > 0)
                      Positioned(
                        top: 2,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.statusDisconnected,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${notifProvider.unreadCount}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Profile & Settings
                _buildNavItem(
                  index: 3,
                  icon: Icons.tune_rounded,
                  label: 'Settings',
                  isSelected: _currentIndex == 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.primary;
    final inactiveColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

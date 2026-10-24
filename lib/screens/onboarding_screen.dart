import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'main_navigation_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Track Everything\nIn One Place',
      'subtitle': 'Manage your keys, wallet, backpack, gadgets, and essentials with live Bluetooth telemetry.',
      'icon': Icons.category_rounded,
      'color': AppColors.primary,
      'tag': 'CENTRAL DASHBOARD',
    },
    {
      'title': 'Active Radar &\nAcoustic Beepers',
      'subtitle': 'Trigger high-pitch finding audio alerts and follow precision sonar sweep waves right to your item.',
      'icon': Icons.radar_rounded,
      'color': AppColors.secondary,
      'tag': 'SMART FINDER',
    },
    {
      'title': 'Never Leave Items\nBehind Again',
      'subtitle': 'Receive instant separation warnings and view last-known GPS coordinates when an item disconnects.',
      'icon': Icons.notifications_active_rounded,
      'color': AppColors.primary,
      'tag': 'SMART ALERTS',
    },
  ];

  void _onFinish() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) => const MainNavigationShell(),
        transitionsBuilder: (context, animation, secAnim, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _onFinish,
            child: Text(
              'Skip',
              style: AppTypography.buttonLabel(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  final color = page['color'] as Color;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Illustration
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withValues(alpha: 0.12),
                            border: Border.all(
                              color: color.withValues(alpha: 0.35),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              page['icon'] as IconData,
                              size: 64,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            page['tag'] as String,
                            style: AppTypography.monoLabel(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Title
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: AppTypography.displayMedium(context, isDark: isDark).copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          page['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium(context, isDark: isDark).copyWith(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Dots & CTA Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _onFinish();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                        style: AppTypography.buttonLabel(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

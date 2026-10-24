import 'package:flutter/material.dart';
import '../models/item_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CategoryFilterBar extends StatelessWidget {
  final ItemCategory? selectedCategory;
  final Function(ItemCategory?) onSelectCategory;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // "All" Category Pill
          _buildCategoryPill(
            context: context,
            label: 'All Items',
            icon: Icons.grid_view_rounded,
            isSelected: selectedCategory == null,
            color: AppColors.primary,
            onTap: () => onSelectCategory(null),
          ),
          const SizedBox(width: 8),

          // Categories
          ...ItemCategory.values.map((category) {
            final isSelected = selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildCategoryPill(
                context: context,
                label: category.displayName,
                icon: category.icon,
                isSelected: isSelected,
                color: category.color,
                onTap: () => onSelectCategory(category),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryPill({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark
                  ? AppColors.surfaceDarkElevated
                  : AppColors.surfaceLightElevated),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.bodySmall(context, isDark: isDark).copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

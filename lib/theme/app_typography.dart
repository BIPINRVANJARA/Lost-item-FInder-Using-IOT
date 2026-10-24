import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Display Large
  static TextStyle displayLarge(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      height: 1.15,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }

  // Display Medium
  static TextStyle displayMedium(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      height: 1.2,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }

  // Headline
  static TextStyle headline(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }

  // Title
  static TextStyle title(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }

  // Body Medium
  static TextStyle bodyMedium(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
    );
  }

  // Body Small
  static TextStyle bodySmall(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
    );
  }

  // Monospace Label (for RSSI, coordinates, timestamps, battery %, technical telemetry)
  static TextStyle monoLabel({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0.2,
      color: color ?? AppColors.primary,
    );
  }

  // Button Label
  static TextStyle buttonLabel({Color color = Colors.white}) {
    return GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: color,
    );
  }
}

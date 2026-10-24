import 'package:flutter/material.dart';

class AppColors {
  // Brand tokens from Neuform spec
  static const Color primary = Color(0xFF10B981); // Emerald #10B981
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF34D399);

  static const Color secondary = Color(0xFF8B5CF6); // Purple #8B5CF6
  static const Color secondaryDark = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFA78BFA);

  static const Color accent = Color(0xFF8B5CF6);

  // Dark Theme Surfaces
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF161F30);
  static const Color surfaceDarkCard = Color(0xFF1E293B);
  static const Color surfaceDarkElevated = Color(0xFF26334D);
  static const Color surfaceDarkAccent = Color(0xFF1B2337);
  static const Color borderDark = Color(0xFF334155);

  // Light Theme Surfaces
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightCard = Color(0xFFFFFFFF);
  static const Color surfaceLightElevated = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Status & Telemetry
  static const Color statusConnected = Color(0xFF10B981);
  static const Color statusNearby = Color(0xFF38BDF8); // Sky Blue
  static const Color statusDisconnected = Color(0xFFF43F5E); // Rose
  static const Color statusUnknown = Color(0xFF94A3B8); // Slate
  static const Color statusWarning = Color(0xFFF59E0B); // Amber
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

import 'package:flutter/material.dart';

/// App color constants - Blinkit inspired green/white theme
class AppColors {
  AppColors._();

  // Primary Colors - Blinkit Green
  static const Color primary = Color(0xFF0C831F);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color primaryDark = Color(0xFF0A6B19);
  
  // Accent Colors
  static const Color accent = Color(0xFF0C831F);
  static const Color accentLight = Color(0xFFE8F5E9);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0C831F), Color(0xFF0A6B19)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF0C831F), Color(0xFF0A6B19)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F8F8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F8F8);
  static const Color surfaceDark = Color(0xFFEEEEEE);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  
  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  
  // Status Colors
  static const Color success = Color(0xFF0C831F);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
  
  // Order Status Colors
  static const Color statusPending = Color(0xFFFFA000);
  static const Color statusConfirmed = Color(0xFF1976D2);
  static const Color statusPreparing = Color(0xFF7B1FA2);
  static const Color statusDelivered = Color(0xFF388E3C);
  static const Color statusCancelled = Color(0xFFD32F2F);
  
  // Shadows
  static const Color shadow = Color(0x08000000);
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowStrong = Color(0x20000000);
  
  // Overlay Colors
  static const Color overlayLight = Color(0x0FFFFFFF);
  static const Color overlayMedium = Color(0x1FFFFFFF);
  static const Color overlayDark = Color(0x33FFFFFF);
  
  // Special
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  
  // Shimmer
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  
  // Hover
  static const Color hoverLight = Color(0x0A000000);
  static const Color hoverMedium = Color(0x14000000);
}

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Color - Calm & Professional
  static const Color primary = Color(0xFF2E7D32); // Calm Green
  static const Color primaryLight = Color(0xFF4CAF50); // Lighter Green
  static const Color primaryDark = Color(0xFF1B5E20); // Darker Green
  static const Color accent = Color(0xFF455A64); // Blue Grey for accents
  static const Color accentLight = Color(0xFF607D8B);

  // Background Colors - Clean & Minimal
  static const Color background = Color(0xFFFAFAFA); // Very Light Grey
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceLight = Color(0xFFF5F5F5); // Light Grey
  static const Color surfaceDark = Color(0xFFEEEEEE); // Slightly darker surface
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF455A64), Color(0xFF607D8B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFAFAFA), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Overlay Colors for Glassmorphism
  static const Color overlayLight = Color(0x0FFFFFFF); // 6% white
  static const Color overlayMedium = Color(0x1FFFFFFF); // 12% white
  static const Color overlayDark = Color(0x33FFFFFF); // 20% white

  // Text Colors - High Contrast but Soft
  static const Color textPrimary = Color(0xFF212121); // Almost Black
  static const Color textSecondary = Color(0xFF757575); // Medium Grey
  static const Color textTertiary = Color(0xFFBDBDBD); // Light Grey
  static const Color textHint = Color(0xFFEEEEEE); // Ultra Light Grey

  // Status Colors
  static const Color success = Color(0xFF43A047); // Green
  static const Color error = Color(0xFFE53935); // Red
  static const Color warning = Color(0xFFFB8C00); // Orange
  static const Color info = Color(0xFF1E88E5); // Blue

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFF0F0F0);

  // Order Status Colors
  static const Color statusPending = Color(0xFFFFA000);
  static const Color statusConfirmed = Color(0xFF1976D2);
  static const Color statusPreparing = Color(0xFF7B1FA2);
  static const Color statusDelivered = Color(0xFF388E3C);
  static const Color statusCancelled = Color(0xFFD32F2F);

  // Availability
  static const Color inStock = Color(0xFF388E3C);
  static const Color outOfStock = Color(0xFFD32F2F);
  static const Color lowStock = Color(0xFFFBC02D);

  // Shadows
  static const Color shadow = Color(0x08000000); // 3% opacity black
  static const Color shadowMedium = Color(0x10000000); // 6% opacity black
  static const Color shadowStrong = Color(0x20000000); // 12% opacity black
  
  // Shimmer Colors for Loading States
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  
  // Hover States (for web/desktop)
  static const Color hoverLight = Color(0x0A000000); // 4% black
  static const Color hoverMedium = Color(0x14000000); // 8% black
}

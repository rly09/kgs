import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Color - Calm & Professional
  // Using a softer, more sophisticated green or even a neutral charcoal if preferred.
  // Keeping a "Fresh Green" but slightly desaturated/calmer for a premium feel.
  static const Color primary = Color(0xFF2E7D32); // Calm Green
  static const Color accent = Color(0xFF455A64); // Blue Grey for accents

  // Background Colors - Clean & Minimal
  static const Color background = Color(0xFFFAFAFA); // Very Light Grey (almost white)
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceLight = Color(0xFFF5F5F5); // Light Grey

  // Text Colors - High Contrast but Soft
  static const Color textPrimary = Color(0xFF212121); // Almost Black
  static const Color textSecondary = Color(0xFF757575); // Medium Grey
  static const Color textTertiary = Color(0xFFBDBDBD); // Light Grey
  static const Color textHint = Color(0xFFEEEEEE); // Ultra Light Grey

  // Status Colors - Muted Pastel Tones preferred for minimal look
  // but need enough contrast for accessibility.
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

  // Shadows - Extremely subtle
  static const Color shadow = Color(0x08000000); // 3% opacity black
  static const Color shadowMedium = Color(0x10000000); // 6% opacity black
}

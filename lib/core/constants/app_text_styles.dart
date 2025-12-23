import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system - Modern, readable, hierarchical
class AppTextStyles {
  AppTextStyles._();

  // Primary Font Family - Outfit for a modern, clean look
  static final TextStyle _baseStyle = GoogleFonts.outfit(
    color: AppColors.textPrimary,
  );

  // Headings - Clean & Bold
  static final TextStyle heading1 = _baseStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static final TextStyle heading2 = _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  static final TextStyle heading3 = _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Body Text - Readable & Clear
  static final TextStyle bodyLarge = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static final TextStyle bodyMedium = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static final TextStyle bodySmall = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Button Text
  static final TextStyle button = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  // Minimal Label
  static final TextStyle label = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  // Price - Simple & Bold
  static final TextStyle price = _baseStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // --- Compatibility Styles (Mapped to minimal styles) ---
  
  static final TextStyle heading4 = heading3.copyWith(fontSize: 18);
  
  static final TextStyle caption = bodySmall;
  
  static final TextStyle buttonSmall = button.copyWith(fontSize: 14);
  
  static final TextStyle labelSmall = label.copyWith(fontSize: 11);
  
  static final TextStyle priceSmall = price.copyWith(fontSize: 16);
  
  static final TextStyle badge = bodySmall.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
  
  static final TextStyle chip = bodyMedium;
}

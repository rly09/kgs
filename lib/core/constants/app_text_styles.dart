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

  // Display Styles - For hero sections and large text
  static final TextStyle display1 = _baseStyle.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.0,
    height: 1.2,
  );

  static final TextStyle display2 = _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.8,
    height: 1.2,
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

  static final TextStyle heading4 = _baseStyle.copyWith(
    fontSize: 18,
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
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static final TextStyle buttonSmall = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Colors.white,
  );
  
  // Labels
  static final TextStyle label = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  static final TextStyle labelSmall = _baseStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  static final TextStyle labelLarge = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  // Price - Simple & Bold
  static final TextStyle price = _baseStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static final TextStyle priceSmall = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static final TextStyle priceLarge = _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // Special Styles
  static final TextStyle caption = bodySmall;
  
  static final TextStyle badge = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
  
  static final TextStyle chip = bodyMedium.copyWith(
    fontWeight: FontWeight.w500,
  );

  static final TextStyle overline = _baseStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  // Responsive text scaling helper
  static TextStyle responsive(TextStyle style, BuildContext context, {
    double mobileScale = 1.0,
    double tabletScale = 1.1,
    double desktopScale = 1.2,
  }) {
    final width = MediaQuery.of(context).size.width;
    double scale = mobileScale;
    
    if (width >= 1024) {
      scale = desktopScale;
    } else if (width >= 600) {
      scale = tabletScale;
    }
    
    return style.copyWith(fontSize: (style.fontSize ?? 14) * scale);
  }
}


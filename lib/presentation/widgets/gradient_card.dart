import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// A modern card with optional gradient background and glassmorphism effect
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? backgroundColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool enableGlassmorphism;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.backgroundColor,
    this.elevation,
    this.padding,
    this.margin,
    this.borderRadius,
    this.enableGlassmorphism = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? 
        BorderRadius.circular(AppDimensions.radiusLarge);
    
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.padding),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? (backgroundColor ?? AppColors.cardBackground) : null,
        borderRadius: effectiveBorderRadius,
        border: enableGlassmorphism
            ? Border.all(color: AppColors.overlayLight, width: 1)
            : null,
      ),
      child: child,
    );

    if (enableGlassmorphism) {
      cardContent = ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppDimensions.blurLight,
            sigmaY: AppDimensions.blurLight,
          ),
          child: cardContent,
        ),
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: elevation ?? AppDimensions.elevationSmall,
            offset: Offset(0, (elevation ?? AppDimensions.elevationSmall) / 2),
          ),
        ],
      ),
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: effectiveBorderRadius,
                child: cardContent,
              ),
            )
          : cardContent,
    );
  }
}

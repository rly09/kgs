import 'package:flutter/material.dart';

/// Responsive helper utility for adaptive layouts
class ResponsiveHelper {
  // Breakpoints
  static const double mobileSmall = 360;
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if mobile (< 600dp)
  static bool isMobile(BuildContext context) {
    return screenWidth(context) < mobile;
  }

  /// Check if tablet (600dp - 1024dp)
  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);
    return width >= mobile && width < tablet;
  }

  /// Check if desktop (>= 1024dp)
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= tablet;
  }

  /// Get device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = screenWidth(context);
    if (width < mobile) return DeviceType.mobile;
    if (width < tablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Get responsive value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = screenWidth(context);
    if (width >= ResponsiveHelper.tablet && desktop != null) {
      return desktop;
    }
    if (width >= ResponsiveHelper.mobile && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get adaptive grid columns
  static int getGridColumns(BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    return responsive(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive padding
  static double getResponsivePadding(BuildContext context) {
    return responsive(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context) {
    return responsive(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );
  }

  /// Get responsive card width
  static double getCardWidth(BuildContext context) {
    final width = screenWidth(context);
    if (width >= tablet) {
      return 400; // Fixed width for tablet/desktop
    }
    return width - (getResponsivePadding(context) * 2);
  }

  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final width = screenWidth(context);
    if (width >= desktop) return 600;
    if (width >= tablet) return 500;
    return width * 0.9;
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    return responsive(
      context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
  }

  /// Get max content width for centering on large screens
  static double getMaxContentWidth(BuildContext context) {
    return responsive(
      context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1200,
    );
  }

  /// Check if landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get adaptive child aspect ratio for grid
  static double getGridChildAspectRatio(BuildContext context) {
    return responsive(
      context,
      mobile: 0.75,
      tablet: 0.8,
      desktop: 0.85,
    );
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, {
    double mobile = 24,
    double? tablet,
    double? desktop,
  }) {
    return responsive(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.2,
      desktop: desktop ?? mobile * 1.4,
    );
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    return responsive(
      context,
      mobile: 48.0,
      tablet: 52.0,
      desktop: 56.0,
    );
  }

  /// Wrap content with max width constraint for large screens
  static Widget constrainedContent(
    BuildContext context, {
    required Widget child,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: getMaxContentWidth(context),
        ),
        child: child,
      ),
    );
  }

  /// Get adaptive layout (Row for tablet+, Column for mobile)
  static Widget adaptiveLayout(
    BuildContext context, {
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    if (isMobile(context)) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

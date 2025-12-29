/// Spacing and sizing constants for consistent UI
class AppDimensions {
  AppDimensions._();

  // Spacing
  static const double spaceXSmall = 4.0;
  static const double spaceSmall = 8.0;
  static const double space = 16.0;
  static const double spaceMedium = 16.0; // Alias for space
  static const double spaceLarge = 24.0;
  static const double spaceXLarge = 32.0;
  static const double spaceXXLarge = 48.0;

  // Padding
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double padding = 16.0;
  static const double paddingMedium = 16.0; // Alias for padding
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double paddingXXLarge = 32.0;

  // Border Radius - Slightly softer corners
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radius = radiusLarge; // Map 'radius' to 16.0
  static const double radiusRound = 100.0; // For circular shapes

  // Component Heights
  static const double buttonHeight = 56.0; // Easier to tap
  static const double inputHeight = 56.0;
  static const double appBarHeight = 64.0;
  static const double bottomNavHeight = 72.0;

  // Icon Sizes
  static const double iconXSmall = 12.0;
  static const double iconSmall = 16.0;
  static const double iconSizeSmall = 16.0;
  static const double icon = 24.0;
  static const double iconSizeMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconSizeLarge = 32.0;
  static const double iconXLarge = 48.0;
  static const double iconXXLarge = 64.0;

  // Elevation
  static const double elevationSmall = 2.0;
  static const double elevation = 4.0;
  static const double elevationMedium = 6.0;
  static const double elevationLarge = 8.0;
  static const double elevationXLarge = 12.0;

  // Animation Durations (in milliseconds)
  static const int animationFast = 200;
  static const int animationNormal = 300;
  static const int animationSlow = 500;
  static const int animationVerySlow = 800;

  // Blur Radius for Glassmorphism
  static const double blurLight = 10.0;
  static const double blurMedium = 20.0;
  static const double blurStrong = 30.0;

  // Max Content Width for Large Screens
  static const double maxContentWidthMobile = double.infinity;
  static const double maxContentWidthTablet = 800.0;
  static const double maxContentWidthDesktop = 1200.0;
}


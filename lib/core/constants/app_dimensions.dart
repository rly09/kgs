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

  // Border Radius - Slightly softer corners
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Component Heights
  static const double buttonHeight = 56.0; // Easier to tap
  static const double inputHeight = 56.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // --- Compatibility Dimensions ---
  static const double radius = radiusLarge; // Map 'radius' to 16.0
  static const double radiusRound = 100.0; // For circular shapes
  
  static const double paddingXXLarge = 32.0; // Restoring for compatibility if used
  static const double elevationSmall = 2.0; // Restoring
  static const double elevation = 4.0; // Restoring

  static const double iconSmall = iconSizeSmall;
  static const double icon = iconSizeMedium;
  static const double iconLarge = iconSizeLarge;
  static const double iconXLarge = 48.0;
  static const double iconXSmall = 12.0;
}

import 'package:latlong2/latlong.dart';

/// App configuration including shop location
class AppConfig {
  AppConfig._();

  // Default shop location - UPDATE THIS WITH YOUR ACTUAL SHOP COORDINATES
  // Example: Delhi, India
  static const LatLng shopLocation = LatLng(26.869425, 88.739276);
  
  // Shop address for display
  static const String shopAddress = 'KGS Shop, Mal Bazar, West Bengal';
  
  // You can update these coordinates to your actual shop location:
  // 1. Go to https://www.openstreetmap.org/
  // 2. Find your shop location
  // 3. Right-click and select "Show address"
  // 4. Copy the latitude and longitude
  // 5. Update the shopLocation above
}

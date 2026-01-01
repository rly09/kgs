import 'package:latlong2/latlong.dart';

/// App configuration including shop location
class AppConfig {
  AppConfig._();

  // Default shop location - UPDATE THIS WITH YOUR ACTUAL SHOP COORDINATES
  // Example: Delhi, India
  static const LatLng shopLocation = LatLng(26.935546, 75.764841);
  
  // Shop address for display
  static const String shopAddress = 'KGS Shop, Jaipur, Rajasthan';
  
  // You can update these coordinates to your actual shop location:
  // 1. Go to https://www.openstreetmap.org/
  // 2. Find your shop location
  // 3. Right-click and select "Show address"
  // 4. Copy the latitude and longitude
  // 5. Update the shopLocation above
}

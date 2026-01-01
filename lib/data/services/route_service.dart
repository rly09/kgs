import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/route_model.dart';

/// Service for fetching delivery routes
class RouteService {
  // OSRM API (free, no key needed)
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  /// Get route from start to end coordinates
  /// Returns RouteModel with coordinates, distance, and duration
  Future<RouteModel> getRoute(LatLng start, LatLng end) async {
    try {
      // Try OSRM API (free, no auth needed)
      final url = Uri.parse(
        '$_baseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          final coordinates = (geometry['coordinates'] as List)
              .map((coord) => LatLng(coord[1] as double, coord[0] as double))
              .toList();

          final distanceMeters = route['distance'] as num;
          final durationSeconds = route['duration'] as num;

          return RouteModel(
            coordinates: coordinates,
            distanceKm: distanceMeters / 1000,
            durationMinutes: (durationSeconds / 60).round(),
          );
        }
      }
      
      // Fallback: Create simple straight line route
      return _createStraightLineRoute(start, end);
    } catch (e) {
      // Fallback: Create simple straight line route
      return _createStraightLineRoute(start, end);
    }
  }

  /// Create a simple straight line route (fallback)
  RouteModel _createStraightLineRoute(LatLng start, LatLng end) {
    // Create intermediate points for smoother line
    final coordinates = <LatLng>[];
    const steps = 10;
    
    for (int i = 0; i <= steps; i++) {
      final ratio = i / steps;
      final lat = start.latitude + (end.latitude - start.latitude) * ratio;
      final lng = start.longitude + (end.longitude - start.longitude) * ratio;
      coordinates.add(LatLng(lat, lng));
    }

    final distance = calculateDistance(start, end);
    final duration = (distance * 3).round(); // Estimate: 3 min per km

    return RouteModel(
      coordinates: coordinates,
      distanceKm: distance,
      durationMinutes: duration,
    );
  }

  /// Calculate straight-line distance between two points
  double calculateDistance(LatLng start, LatLng end) {
    const distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  }
}

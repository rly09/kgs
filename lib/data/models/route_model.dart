import 'package:latlong2/latlong.dart';

/// Route model for delivery navigation
class RouteModel {
  final List<LatLng> coordinates;
  final double distanceKm;
  final int durationMinutes;

  RouteModel({
    required this.coordinates,
    required this.distanceKm,
    required this.durationMinutes,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final features = json['features'] as List;
    if (features.isEmpty) {
      throw Exception('No route found');
    }

    final geometry = features[0]['geometry'];
    final coordinates = (geometry['coordinates'] as List)
        .map((coord) => LatLng(coord[1] as double, coord[0] as double))
        .toList();

    final properties = features[0]['properties'];
    final summary = properties['summary'];

    return RouteModel(
      coordinates: coordinates,
      distanceKm: (summary['distance'] as num) / 1000, // meters to km
      durationMinutes: ((summary['duration'] as num) / 60).round(), // seconds to minutes
    );
  }
}

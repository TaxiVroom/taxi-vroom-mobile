import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';

// One item of `routes` in the Mapbox Directions API response, requested with
// geometries=geojson.
class RideRouteModel {
  const RideRouteModel({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.path,
  });

  factory RideRouteModel.fromJson(Map<String, dynamic> route) {
    final geometry = route['geometry'] as Map<String, dynamic>;
    return RideRouteModel(
      distanceMeters: (route['distance'] as num).toDouble(),
      durationSeconds: (route['duration'] as num).toDouble(),
      path: [
        // GeoJSON order: [longitude, latitude].
        for (final point in geometry['coordinates'] as List<dynamic>)
          (
            latitude: ((point as List<dynamic>)[1] as num).toDouble(),
            longitude: (point[0] as num).toDouble(),
          ),
      ],
    );
  }

  final double distanceMeters;
  final double durationSeconds;
  final List<({double latitude, double longitude})> path;

  RideRoute toDomain() => RideRoute(
    distanceKm: distanceMeters / 1000,
    durationMinutes: (durationSeconds / 60).round(),
    path: [
      for (final point in path)
        Coordinates(latitude: point.latitude, longitude: point.longitude),
    ],
  );
}

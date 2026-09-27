import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';

// One feature of the Mapbox Search Box API /retrieve FeatureCollection.
class PlaceModel {
  const PlaceModel({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String address;
  final double latitude;
  final double longitude;

  factory PlaceModel.fromJson(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    // GeoJSON order: [longitude, latitude].
    final coordinates = geometry['coordinates'] as List<dynamic>;
    return PlaceModel(
      name: properties['name'] as String,
      address:
          (properties['full_address'] ?? properties['place_formatted'] ?? '')
              as String,
      longitude: (coordinates[0] as num).toDouble(),
      latitude: (coordinates[1] as num).toDouble(),
    );
  }

  Place toDomain() => Place(
    name: name,
    address: address,
    coordinates: Coordinates(latitude: latitude, longitude: longitude),
  );
}

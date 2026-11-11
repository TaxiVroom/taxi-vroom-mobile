import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/recent_destination.dart';

// GET /v1/rides/recent-destinations, e.g. {"name":"Gare de Strasbourg",
// "latitude":48.5851,"longitude":7.7346}.
class RecentDestinationModel {
  const RecentDestinationModel({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory RecentDestinationModel.fromJson(Map<String, dynamic> json) =>
      RecentDestinationModel(
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );

  final String name;
  final double latitude;
  final double longitude;

  RecentDestination toDomain() => RecentDestination(
    name: name,
    coordinates: Coordinates(latitude: latitude, longitude: longitude),
  );
}

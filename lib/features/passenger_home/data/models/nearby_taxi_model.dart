import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';

class NearbyTaxiModel {
  const NearbyTaxiModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.isAvailable,
  });

  factory NearbyTaxiModel.fromJson(Map<String, dynamic> json) =>
      NearbyTaxiModel(
        id: json['id'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        isAvailable: json['available'] as bool,
      );

  final String id;
  final double latitude;
  final double longitude;
  final bool isAvailable;

  NearbyTaxi toDomain() => NearbyTaxi(
    id: id,
    position: Coordinates(latitude: latitude, longitude: longitude),
    isAvailable: isAvailable,
  );
}

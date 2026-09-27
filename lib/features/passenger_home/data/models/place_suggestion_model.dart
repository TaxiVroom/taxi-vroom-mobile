import 'package:mobile/features/passenger_home/domain/entities/place_suggestion.dart';

// One item of `suggestions` in the Mapbox Search Box API /suggest response.
class PlaceSuggestionModel {
  const PlaceSuggestionModel({
    required this.mapboxId,
    required this.name,
    required this.address,
    this.distanceMeters,
  });

  factory PlaceSuggestionModel.fromJson(Map<String, dynamic> json) =>
      PlaceSuggestionModel(
        mapboxId: json['mapbox_id'] as String,
        name: json['name'] as String,
        address:
            (json['full_address'] ?? json['place_formatted'] ?? '') as String,
        distanceMeters: (json['distance'] as num?)?.toDouble(),
      );

  final String mapboxId;
  final String name;
  final String address;
  final double? distanceMeters;

  PlaceSuggestion toDomain() => PlaceSuggestion(
    id: mapboxId,
    name: name,
    address: address,
    distanceKm: distanceMeters == null ? null : distanceMeters! / 1000,
  );
}

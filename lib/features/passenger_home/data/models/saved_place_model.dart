import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';

// GET /v1/me/saved-places, e.g. {"kind":"HOME","address":"3 Rue du Dôme
// 67000 Strasbourg","latitude":48.5833,"longitude":7.7485}.
class SavedPlaceModel {
  const SavedPlaceModel({
    required this.kind,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory SavedPlaceModel.fromDomain(SavedPlace place) => SavedPlaceModel(
    kind: place.kind,
    address: place.address,
    latitude: place.coordinates.latitude,
    longitude: place.coordinates.longitude,
  );

  factory SavedPlaceModel.fromJson(Map<String, dynamic> json) =>
      SavedPlaceModel(
        kind: kindFromJson(json['kind'] as String),
        address: json['address'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );

  final SavedPlaceKind kind;
  final String address;
  final double latitude;
  final double longitude;

  static SavedPlaceKind kindFromJson(String kind) => switch (kind) {
    'WORK' => SavedPlaceKind.work,
    _ => SavedPlaceKind.home,
  };

  static String kindToJson(SavedPlaceKind kind) => switch (kind) {
    SavedPlaceKind.home => 'HOME',
    SavedPlaceKind.work => 'WORK',
  };

  // PATCH /v1/me/saved-places/:kind: the kind is in the path.
  Map<String, dynamic> toLocationJson() => {
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
  };

  Map<String, dynamic> toJson() => {
    'kind': kindToJson(kind),
    ...toLocationJson(),
  };

  SavedPlace toDomain() => SavedPlace(
    kind: kind,
    address: address,
    coordinates: Coordinates(latitude: latitude, longitude: longitude),
  );
}

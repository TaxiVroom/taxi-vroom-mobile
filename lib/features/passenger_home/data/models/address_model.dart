import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';

// The properties of one feature of the Géoplateforme /geocodage/reverse
// FeatureCollection, e.g. name "20 Place de la Gare", postcode "67000",
// city "Strasbourg".
class AddressModel {
  const AddressModel({
    required this.name,
    required this.postcode,
    required this.city,
  });

  factory AddressModel.fromJson(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>;
    return AddressModel(
      name: properties['name'] as String,
      postcode: (properties['postcode'] ?? '') as String,
      city: (properties['city'] ?? '') as String,
    );
  }

  final String name;
  final String postcode;
  final String city;

  // At the point the passenger chose, not at the address found near it.
  Place toDomain(Coordinates point) => Place(
    name: name,
    address: '$postcode $city'.trim(),
    coordinates: point,
  );
}

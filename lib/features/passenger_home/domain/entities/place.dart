import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';

// A chosen destination, with its exact position.
class Place extends Equatable {
  const Place({
    required this.name,
    required this.address,
    required this.coordinates,
  });

  final String name;
  final String address;
  final Coordinates coordinates;

  // Mapbox's full address, e.g. "4 Rue de la Magel, 67000 Strasbourg,
  // France"; its name when Mapbox gives none.
  String get fullAddress => address.isEmpty ? name : address;

  @override
  List<Object?> get props => [name, address, coordinates];
}

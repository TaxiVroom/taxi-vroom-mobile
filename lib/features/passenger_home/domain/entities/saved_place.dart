import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';

// "Maison" or "Travail": one of each at most. Spec
// taxi-vroom-api/docs/specs/maison-et-travail.md.
enum SavedPlaceKind {
  home('Maison'),
  work('Travail');

  const SavedPlaceKind(this.label);

  final String label;
}

// An address the passenger saved, a destination in one tap.
class SavedPlace extends Equatable {
  const SavedPlace({
    required this.kind,
    required this.address,
    required this.coordinates,
  });

  // A place chosen from Mapbox, kept like a ride's destination: its full
  // address, or its name when Mapbox gives none. Spec
  // taxi-vroom-api/docs/specs/maison-et-travail.md.
  factory SavedPlace.fromPlace(SavedPlaceKind kind, Place place) => SavedPlace(
    kind: kind,
    address: place.fullAddress,
    coordinates: place.coordinates,
  );

  final SavedPlaceKind kind;

  // e.g. "4 Rue de la Magel, 67000 Strasbourg, France".
  final String address;
  final Coordinates coordinates;

  // The driver and the history see the address, not "Maison".
  Place toDestination() =>
      Place(name: address, address: address, coordinates: coordinates);

  @override
  List<Object?> get props => [kind, address, coordinates];
}

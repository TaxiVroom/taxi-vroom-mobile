import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';

// Everything the passenger home screen shows.
class PassengerHome extends Equatable {
  const PassengerHome({required this.position, required this.savedPlaces});

  final Coordinates position;

  // "Maison" and "Travail", only those set.
  final List<SavedPlace> savedPlaces;

  // Where the taxi picks the passenger up: the place they chose, otherwise
  // where the phone is.
  Coordinates pickupAt(Place? chosen) => chosen?.coordinates ?? position;

  PassengerHome withPosition(Coordinates position) =>
      PassengerHome(position: position, savedPlaces: savedPlaces);

  SavedPlace? savedPlaceOf(SavedPlaceKind kind) =>
      savedPlaces.where((place) => place.kind == kind).firstOrNull;

  // Added or changed: it replaces the place of the same kind.
  PassengerHome withSavedPlace(SavedPlace place) => _withSavedPlaces([
    ...withoutSavedPlace(place.kind).savedPlaces,
    place,
  ]);

  PassengerHome withoutSavedPlace(SavedPlaceKind kind) => _withSavedPlaces([
    for (final place in savedPlaces)
      if (place.kind != kind) place,
  ]);

  PassengerHome _withSavedPlaces(List<SavedPlace> savedPlaces) =>
      PassengerHome(position: position, savedPlaces: savedPlaces);

  @override
  List<Object?> get props => [position, savedPlaces];
}

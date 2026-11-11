part of 'saved_place_bloc.dart';

sealed class SavedPlaceEvent extends Equatable {
  const SavedPlaceEvent();

  @override
  List<Object?> get props => [];
}

// A suggestion or a point on the map was chosen, with its Mapbox address.
final class SavedPlaceChosen extends SavedPlaceEvent {
  const SavedPlaceChosen({required this.place});

  final Place place;

  @override
  List<Object?> get props => [place];
}

// "Supprimer".
final class SavedPlaceDeleteRequested extends SavedPlaceEvent {
  const SavedPlaceDeleteRequested();
}

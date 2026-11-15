part of 'passenger_home_bloc.dart';

sealed class PassengerHomeEvent extends Equatable {
  const PassengerHomeEvent();

  @override
  List<Object?> get props => [];
}

// The home screen is shown, or the passenger taps "Réessayer".
final class PassengerHomeStarted extends PassengerHomeEvent {
  const PassengerHomeStarted();
}

// The passenger is about to order from the home: "Position actuelle" is read
// again, unless [chosen], the pickup they picked, replaces it.
final class PassengerPositionRefreshed extends PassengerHomeEvent {
  const PassengerPositionRefreshed({required this.chosen});

  final Place? chosen;

  @override
  List<Object?> get props => [chosen];
}

// "Maison" or "Travail" was added or changed.
final class PassengerSavedPlaceStored extends PassengerHomeEvent {
  const PassengerSavedPlaceStored({required this.place});

  final SavedPlace place;

  @override
  List<Object?> get props => [place];
}

final class PassengerSavedPlaceRemoved extends PassengerHomeEvent {
  const PassengerSavedPlaceRemoved({required this.kind});

  final SavedPlaceKind kind;

  @override
  List<Object?> get props => [kind];
}

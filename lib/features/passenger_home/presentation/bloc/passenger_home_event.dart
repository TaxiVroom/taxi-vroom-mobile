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

// The device lost or got back its connection.
final class PassengerConnectionChanged extends PassengerHomeEvent {
  const PassengerConnectionChanged({required this.isConnected});

  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}

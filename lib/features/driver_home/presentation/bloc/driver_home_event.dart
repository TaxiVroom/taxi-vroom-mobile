part of 'driver_home_bloc.dart';

sealed class DriverHomeEvent extends Equatable {
  const DriverHomeEvent();

  @override
  List<Object?> get props => [];
}

// The home screen is shown, or the driver taps "Réessayer".
final class DriverHomeStarted extends DriverHomeEvent {
  const DriverHomeStarted();
}

// "Passer en ligne" / "Passer hors ligne".
final class DriverOnlineToggled extends DriverHomeEvent {
  const DriverOnlineToggled({required this.isOnline});

  final bool isOnline;

  @override
  List<Object?> get props => [isOnline];
}

// "Recevoir les réservations" switch.
final class DriverBookingsToggled extends DriverHomeEvent {
  const DriverBookingsToggled({required this.receivesBookings});

  final bool receivesBookings;

  @override
  List<Object?> get props => [receivesBookings];
}

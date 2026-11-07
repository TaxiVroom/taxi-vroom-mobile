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

// While online, the device lost or got back its connection.
final class DriverConnectionChanged extends DriverHomeEvent {
  const DriverConnectionChanged({required this.isConnected});

  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}

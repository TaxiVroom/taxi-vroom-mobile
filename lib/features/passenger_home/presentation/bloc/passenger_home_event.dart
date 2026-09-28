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

// The device lost or got back its connection.
final class PassengerConnectionChanged extends PassengerHomeEvent {
  const PassengerConnectionChanged({required this.isConnected});

  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}

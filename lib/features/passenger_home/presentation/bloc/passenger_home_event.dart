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

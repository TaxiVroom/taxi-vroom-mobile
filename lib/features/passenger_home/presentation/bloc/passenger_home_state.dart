part of 'passenger_home_bloc.dart';

sealed class PassengerHomeState extends Equatable {
  const PassengerHomeState();

  @override
  List<Object?> get props => [];
}

final class PassengerHomeLoading extends PassengerHomeState {
  const PassengerHomeLoading();
}

final class PassengerHomeReady extends PassengerHomeState {
  const PassengerHomeReady({required this.home});

  final PassengerHome home;

  @override
  List<Object?> get props => [home];
}

final class PassengerHomeFailure extends PassengerHomeState {
  const PassengerHomeFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

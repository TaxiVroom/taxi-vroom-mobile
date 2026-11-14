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
  const PassengerHomeReady({
    required this.home,
    this.nearbyTaxis = const [],
  });

  final PassengerHome home;

  // The free taxis the passenger can order, closest first.
  final List<NearbyTaxi> nearbyTaxis;

  @override
  List<Object?> get props => [home, nearbyTaxis];
}

final class PassengerHomeFailure extends PassengerHomeState {
  const PassengerHomeFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

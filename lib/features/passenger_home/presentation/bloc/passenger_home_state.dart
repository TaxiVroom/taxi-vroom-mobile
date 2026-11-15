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
    this.isLocating = false,
    this.locationFailure,
  });

  final PassengerHome home;

  // The free taxis the passenger can order, closest first.
  final List<NearbyTaxi> nearbyTaxis;

  // The position is being read again, to order from where the phone is now.
  final bool isLocating;

  // Why the last reading failed; null if it did not.
  final Failure? locationFailure;

  PassengerHomeReady copyWith({
    PassengerHome? home,
    List<NearbyTaxi>? nearbyTaxis,
    bool? isLocating,
    Failure? locationFailure,
  }) => PassengerHomeReady(
    home: home ?? this.home,
    nearbyTaxis: nearbyTaxis ?? this.nearbyTaxis,
    isLocating: isLocating ?? this.isLocating,
    locationFailure: locationFailure,
  );

  @override
  List<Object?> get props => [home, nearbyTaxis, isLocating, locationFailure];
}

final class PassengerHomeFailure extends PassengerHomeState {
  const PassengerHomeFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

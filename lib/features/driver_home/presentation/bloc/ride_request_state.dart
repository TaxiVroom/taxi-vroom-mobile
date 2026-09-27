part of 'ride_request_bloc.dart';

sealed class RideRequestState extends Equatable {
  const RideRequestState();

  @override
  List<Object?> get props => [];
}

// Online with no request on screen, or offline.
final class RideRequestWaiting extends RideRequestState {
  const RideRequestWaiting();
}

// Mockup screen 4: a request waits for the driver's answer.
final class RideRequestOffered extends RideRequestState {
  const RideRequestOffered({
    required this.offer,
    required this.secondsLeft,
    this.isResponding = false,
    this.failureMessage,
  });

  final RoutedRideRequest offer;
  final int secondsLeft;

  // Accepting or declining is in progress.
  final bool isResponding;

  // Why accepting failed.
  final String? failureMessage;

  RideRequestOffered copyWith({int? secondsLeft, bool? isResponding}) =>
      RideRequestOffered(
        offer: offer,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        isResponding: isResponding ?? this.isResponding,
        failureMessage: failureMessage,
      );

  @override
  List<Object?> get props => [
    offer,
    secondsLeft,
    isResponding,
    failureMessage,
  ];
}

// The driver accepted: they now drive to the passenger.
final class RideRequestTaken extends RideRequestState {
  const RideRequestTaken({required this.ride});

  final DriverRide ride;

  @override
  List<Object?> get props => [ride];
}

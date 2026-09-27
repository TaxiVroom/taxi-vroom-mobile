part of 'ride_request_bloc.dart';

sealed class RideRequestEvent extends Equatable {
  const RideRequestEvent();

  @override
  List<Object?> get props => [];
}

// The driver went online: requests can come in.
final class RideRequestsWatched extends RideRequestEvent {
  const RideRequestsWatched({required this.driverPosition});

  final Coordinates driverPosition;

  @override
  List<Object?> get props => [driverPosition];
}

// The driver went offline.
final class RideRequestsUnwatched extends RideRequestEvent {
  const RideRequestsUnwatched();
}

final class RideRequestAccepted extends RideRequestEvent {
  const RideRequestAccepted();
}

final class RideRequestDeclined extends RideRequestEvent {
  const RideRequestDeclined();
}

final class _RideRequestReceived extends RideRequestEvent {
  const _RideRequestReceived(this.result);

  final Result<RoutedRideRequest> result;

  @override
  List<Object?> get props => [result];
}

// One second of the countdown went by.
final class _RideRequestTicked extends RideRequestEvent {
  const _RideRequestTicked();
}

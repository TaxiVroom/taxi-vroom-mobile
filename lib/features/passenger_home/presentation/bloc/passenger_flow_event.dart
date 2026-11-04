part of 'passenger_flow_bloc.dart';

sealed class PassengerFlowEvent extends Equatable {
  const PassengerFlowEvent();

  @override
  List<Object?> get props => [];
}

// The app started: the passenger may have a ride going on.
final class PassengerFlowStarted extends PassengerFlowEvent {
  const PassengerFlowStarted();
}

// The passenger home could not load: its error shows instead of the start.
final class PassengerHomeFailed extends PassengerFlowEvent {
  const PassengerHomeFailed();
}

// The passenger home is loaded: notifications received on screen or touched
// are followed while it lives.
final class PassengerPushesWatched extends PassengerFlowEvent {
  const PassengerPushesWatched();
}

// A notification about this ride was received on screen or touched.
final class _PassengerPushedRideOpened extends PassengerFlowEvent {
  const _PassengerPushedRideOpened({required this.rideId});

  final String rideId;

  @override
  List<Object?> get props => [rideId];
}

// "Où allez-vous ?".
final class PassengerDestinationSearchOpened extends PassengerFlowEvent {
  const PassengerDestinationSearchOpened();
}

final class PassengerDestinationSelected extends PassengerFlowEvent {
  const PassengerDestinationSelected({required this.destination});

  final Place destination;

  @override
  List<Object?> get props => [destination];
}

// A taxi was ordered right now: the passenger follows the ride.
final class PassengerRideOrdered extends PassengerFlowEvent {
  const PassengerRideOrdered({required this.rideId});

  final String rideId;

  @override
  List<Object?> get props => [rideId];
}

// The ride is over or cancelled: back to a fresh home.
final class PassengerRideEnded extends PassengerFlowEvent {
  const PassengerRideEnded();
}

// A booking waits in "Mes courses": back to a fresh home.
final class PassengerRideBooked extends PassengerFlowEvent {
  const PassengerRideBooked();
}

// The pickup time sheet opens: its days and slots are computed now.
final class PassengerPickupTimeSheetOpened extends PassengerFlowEvent {
  const PassengerPickupTimeSheetOpened();
}

final class PassengerPickupTimeChanged extends PassengerFlowEvent {
  const PassengerPickupTimeChanged({required this.scheduledPickup});

  // Null means "Maintenant".
  final DateTime? scheduledPickup;

  @override
  List<Object?> get props => [scheduledPickup];
}

// The back arrow or the hardware back button.
final class PassengerFlowBackPressed extends PassengerFlowEvent {
  const PassengerFlowBackPressed();
}

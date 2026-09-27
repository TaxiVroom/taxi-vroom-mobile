part of 'passenger_flow_cubit.dart';

sealed class PassengerFlowState extends Equatable {
  const PassengerFlowState({this.scheduledPickup});

  // Null means "as soon as possible", otherwise a booked pickup time.
  final DateTime? scheduledPickup;

  @override
  List<Object?> get props => [scheduledPickup];
}

final class PassengerFlowHome extends PassengerFlowState {
  const PassengerFlowHome({super.scheduledPickup});
}

final class PassengerFlowDestinationSearch extends PassengerFlowState {
  const PassengerFlowDestinationSearch({super.scheduledPickup});
}

// A ride was ordered: the passenger follows it until it ends or is cancelled.
final class PassengerFlowRide extends PassengerFlowState {
  const PassengerFlowRide({required this.rideId, super.scheduledPickup});

  final String rideId;

  @override
  List<Object?> get props => [rideId, scheduledPickup];
}

final class PassengerFlowTaxiChoice extends PassengerFlowState {
  const PassengerFlowTaxiChoice({
    required this.destination,
    super.scheduledPickup,
  });

  final Place destination;

  @override
  List<Object?> get props => [destination, scheduledPickup];
}

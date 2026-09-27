part of 'passenger_flow_bloc.dart';

sealed class PassengerFlowState extends Equatable {
  const PassengerFlowState({
    this.scheduledPickup,
    this.pickupDays = const [],
  });

  // Null means "as soon as possible", otherwise a booked pickup time.
  final DateTime? scheduledPickup;

  // Days and slots offered by the pickup time sheet, computed when it opens.
  final List<PickupDay> pickupDays;

  @override
  List<Object?> get props => [scheduledPickup, pickupDays];
}

final class PassengerFlowHome extends PassengerFlowState {
  const PassengerFlowHome({super.scheduledPickup, super.pickupDays});
}

final class PassengerFlowDestinationSearch extends PassengerFlowState {
  const PassengerFlowDestinationSearch({
    super.scheduledPickup,
    super.pickupDays,
  });
}

// A ride was ordered: the passenger follows it until it ends or is cancelled.
final class PassengerFlowRide extends PassengerFlowState {
  const PassengerFlowRide({required this.rideId, super.scheduledPickup});

  final String rideId;

  @override
  List<Object?> get props => [rideId, scheduledPickup, pickupDays];
}

final class PassengerFlowTaxiChoice extends PassengerFlowState {
  const PassengerFlowTaxiChoice({
    required this.destination,
    super.scheduledPickup,
    super.pickupDays,
  });

  final Place destination;

  @override
  List<Object?> get props => [destination, scheduledPickup, pickupDays];
}

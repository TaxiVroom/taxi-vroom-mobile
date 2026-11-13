part of 'passenger_flow_bloc.dart';

sealed class PassengerFlowState extends Equatable {
  const PassengerFlowState({
    this.scheduledPickup,
    this.pickupDays = const [],
    this.pickupPlace,
    this.passengerCount = 1,
  });

  // Null means "as soon as possible", otherwise a booked pickup time.
  final DateTime? scheduledPickup;

  // How many people travel, from 1 to 8: only taxis with as many seats get
  // the ride. Back to 1 with the home, like the pickup time. Spec
  // taxi-vroom-api/docs/specs/nombre-de-passagers.md.
  final int passengerCount;

  // Days and slots offered by the pickup time sheet, computed when it opens.
  final List<PickupDay> pickupDays;

  // Where the taxi picks the passenger up; null means "Position actuelle",
  // where the phone is (PassengerHome.pickupAt).
  final Place? pickupPlace;

  @override
  List<Object?> get props => [
    scheduledPickup,
    pickupDays,
    pickupPlace,
    passengerCount,
  ];
}

// The app just started: it does not know yet whether a ride must be opened,
// the one of a notification or the current one. Nothing to tap meanwhile.
final class PassengerFlowStarting extends PassengerFlowState {
  const PassengerFlowStarting();
}

final class PassengerFlowHome extends PassengerFlowState {
  const PassengerFlowHome({
    super.scheduledPickup,
    super.pickupDays,
    super.pickupPlace,
    super.passengerCount,
  });
}

final class PassengerFlowDestinationSearch extends PassengerFlowState {
  const PassengerFlowDestinationSearch({
    super.scheduledPickup,
    super.pickupDays,
    super.pickupPlace,
    super.passengerCount,
  });
}

// "Ajouter votre domicile", "Modifier votre lieu de travail"... Spec
// taxi-vroom-api/docs/specs/maison-et-travail.md.
final class PassengerFlowSavedPlaceEdit extends PassengerFlowState {
  const PassengerFlowSavedPlaceEdit({
    required this.kind,
    required this.fromAccount,
    this.current,
    super.scheduledPickup,
    super.pickupPlace,
    super.passengerCount,
  });

  final SavedPlaceKind kind;

  // Null to add it.
  final SavedPlace? current;
  final bool fromAccount;

  @override
  List<Object?> get props => [
    kind,
    current,
    fromAccount,
    scheduledPickup,
    pickupDays,
    pickupPlace,
    passengerCount,
  ];
}

// A ride was ordered: the passenger follows it until it ends or is cancelled.
final class PassengerFlowRide extends PassengerFlowState {
  const PassengerFlowRide({
    required this.rideId,
    super.scheduledPickup,
    super.pickupPlace,
  });

  final String rideId;

  @override
  List<Object?> get props => [rideId, scheduledPickup, pickupDays, pickupPlace];
}

final class PassengerFlowTaxiChoice extends PassengerFlowState {
  const PassengerFlowTaxiChoice({
    required this.destination,
    super.scheduledPickup,
    super.pickupDays,
    super.pickupPlace,
    super.passengerCount,
  });

  final Place destination;

  @override
  List<Object?> get props => [
    destination,
    scheduledPickup,
    pickupDays,
    pickupPlace,
    passengerCount,
  ];
}

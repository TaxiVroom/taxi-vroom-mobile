part of 'taxi_choice_bloc.dart';

sealed class TaxiChoiceEvent extends Equatable {
  const TaxiChoiceEvent();

  @override
  List<Object?> get props => [];
}

// The screen is shown, the passenger taps "Réessayer", or changes the pickup
// time or the passengers: a new estimate for them.
final class TaxiChoiceStarted extends TaxiChoiceEvent {
  const TaxiChoiceStarted({required this.passengerCount, this.scheduledPickup});

  // Null for a taxi now.
  final DateTime? scheduledPickup;

  // How many people travel, from 1 to 8.
  final int passengerCount;

  @override
  List<Object?> get props => [scheduledPickup, passengerCount];
}

// The passenger taps "Commander le taxi", then confirms the [pickup], with
// its Mapbox address.
final class TaxiRideOrdered extends TaxiChoiceEvent {
  const TaxiRideOrdered({required this.pickup});

  final Place pickup;

  @override
  List<Object?> get props => [pickup];
}

// The passenger taps "Réserver le taxi", then confirms the [pickup]: the
// offer was priced for the pickup time.
final class TaxiRideBooked extends TaxiChoiceEvent {
  const TaxiRideBooked({required this.pickup});

  final Place pickup;

  @override
  List<Object?> get props => [pickup];
}

// A taxi became free around the pickup while none was: estimated again.
final class _TaxiChoiceFreeTaxiSeen extends TaxiChoiceEvent {
  const _TaxiChoiceFreeTaxiSeen();
}

final class TaxiOfferSelected extends TaxiChoiceEvent {
  const TaxiOfferSelected({required this.offerId});

  final String offerId;

  @override
  List<Object?> get props => [offerId];
}

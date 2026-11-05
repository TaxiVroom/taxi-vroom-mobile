part of 'taxi_choice_bloc.dart';

sealed class TaxiChoiceEvent extends Equatable {
  const TaxiChoiceEvent();

  @override
  List<Object?> get props => [];
}

// The screen is shown, the passenger taps "Réessayer", or changes the pickup
// time: a new estimate for it.
final class TaxiChoiceStarted extends TaxiChoiceEvent {
  const TaxiChoiceStarted({this.scheduledPickup});

  // Null for a taxi now.
  final DateTime? scheduledPickup;

  @override
  List<Object?> get props => [scheduledPickup];
}

// The passenger taps "Commander le taxi", then confirms the [pickup].
final class TaxiRideOrdered extends TaxiChoiceEvent {
  const TaxiRideOrdered({required this.pickup});

  final Coordinates pickup;

  @override
  List<Object?> get props => [pickup];
}

// The passenger taps "Réserver le taxi", then confirms the [pickup]: the
// offer was priced for the pickup time.
final class TaxiRideBooked extends TaxiChoiceEvent {
  const TaxiRideBooked({required this.pickup});

  final Coordinates pickup;

  @override
  List<Object?> get props => [pickup];
}

final class TaxiOfferSelected extends TaxiChoiceEvent {
  const TaxiOfferSelected({required this.offerId});

  final String offerId;

  @override
  List<Object?> get props => [offerId];
}

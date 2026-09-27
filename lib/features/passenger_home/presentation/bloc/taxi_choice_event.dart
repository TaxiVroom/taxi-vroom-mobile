part of 'taxi_choice_bloc.dart';

sealed class TaxiChoiceEvent extends Equatable {
  const TaxiChoiceEvent();

  @override
  List<Object?> get props => [];
}

// The screen is shown, or the passenger taps "Réessayer".
final class TaxiChoiceStarted extends TaxiChoiceEvent {
  const TaxiChoiceStarted();
}

// The passenger taps "Commander le taxi".
final class TaxiRideOrdered extends TaxiChoiceEvent {
  const TaxiRideOrdered();
}

// The passenger taps "Réserver le taxi", for a pickup later on.
final class TaxiRideBooked extends TaxiChoiceEvent {
  const TaxiRideBooked({required this.scheduledPickup});

  final DateTime scheduledPickup;

  @override
  List<Object?> get props => [scheduledPickup];
}

final class TaxiOfferSelected extends TaxiChoiceEvent {
  const TaxiOfferSelected({required this.offerId});

  final String offerId;

  @override
  List<Object?> get props => [offerId];
}

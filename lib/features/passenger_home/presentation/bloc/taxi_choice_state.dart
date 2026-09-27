part of 'taxi_choice_bloc.dart';

sealed class TaxiChoiceState extends Equatable {
  const TaxiChoiceState();

  @override
  List<Object?> get props => [];
}

final class TaxiChoiceLoading extends TaxiChoiceState {
  const TaxiChoiceLoading();
}

final class TaxiChoiceReady extends TaxiChoiceState {
  const TaxiChoiceReady({
    required this.choice,
    this.selectedOfferId,
    this.isOrdering = false,
    this.orderedRideId,
    this.bookedRideId,
    this.orderFailureMessage,
  });

  final TaxiChoice choice;
  final String? selectedOfferId;

  // An order or a booking is being sent.
  final bool isOrdering;

  // Set once the ride is created: the flow moves on to the ride screen.
  final String? orderedRideId;

  // Set once the ride is booked in advance: the flow goes back home.
  final String? bookedRideId;
  final String? orderFailureMessage;

  @override
  List<Object?> get props => [
    choice,
    selectedOfferId,
    isOrdering,
    orderedRideId,
    bookedRideId,
    orderFailureMessage,
  ];
}

final class TaxiChoiceFailure extends TaxiChoiceState {
  const TaxiChoiceFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

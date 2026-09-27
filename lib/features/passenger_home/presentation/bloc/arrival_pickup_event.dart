part of 'arrival_pickup_bloc.dart';

sealed class ArrivalPickupEvent extends Equatable {
  const ArrivalPickupEvent();

  @override
  List<Object?> get props => [];
}

// The passenger picked an arrival time slot.
final class ArrivalTimeChanged extends ArrivalPickupEvent {
  const ArrivalTimeChanged({required this.arrival});

  final DateTime arrival;

  @override
  List<Object?> get props => [arrival];
}

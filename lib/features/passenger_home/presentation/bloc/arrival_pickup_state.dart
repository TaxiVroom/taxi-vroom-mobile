part of 'arrival_pickup_cubit.dart';

sealed class ArrivalPickupState extends Equatable {
  const ArrivalPickupState();

  // Null until the passenger picks an arrival time.
  DateTime? get arrival;

  @override
  List<Object?> get props => [arrival];
}

final class ArrivalPickupIdle extends ArrivalPickupState {
  const ArrivalPickupIdle();

  @override
  DateTime? get arrival => null;
}

final class ArrivalPickupLoading extends ArrivalPickupState {
  const ArrivalPickupLoading({required this.arrival});

  @override
  final DateTime arrival;
}

final class ArrivalPickupReady extends ArrivalPickupState {
  const ArrivalPickupReady({required this.arrival, required this.pickup});

  @override
  final DateTime arrival;
  final DateTime pickup;

  @override
  List<Object?> get props => [arrival, pickup];
}

final class ArrivalPickupFailure extends ArrivalPickupState {
  const ArrivalPickupFailure({required this.arrival, required this.message});

  @override
  final DateTime arrival;
  final String message;

  @override
  List<Object?> get props => [arrival, message];
}

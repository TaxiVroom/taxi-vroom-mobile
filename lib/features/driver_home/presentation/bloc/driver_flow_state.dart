part of 'driver_flow_bloc.dart';

sealed class DriverFlowState extends Equatable {
  const DriverFlowState();

  @override
  List<Object?> get props => [];
}

final class DriverFlowCheckingDocuments extends DriverFlowState {
  const DriverFlowCheckingDocuments();
}

final class DriverFlowDocumentsFailure extends DriverFlowState {
  const DriverFlowDocumentsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// A document must be sent: mockup screen 1.
final class DriverFlowDocuments extends DriverFlowState {
  const DriverFlowDocuments({required this.documents});

  final DriverDocuments documents;

  @override
  List<Object?> get props => [documents];
}

// The documents, opened from the "Compte" tab.
final class DriverFlowDocumentsReview extends DriverFlowState {
  const DriverFlowDocumentsReview({required this.documents});

  final DriverDocuments documents;

  @override
  List<Object?> get props => [documents];
}

final class DriverFlowHome extends DriverFlowState {
  const DriverFlowHome();
}

// Mockup screen 8: the amount to confirm, then free again.
final class DriverFlowCheckout extends DriverFlowState {
  const DriverFlowCheckout({
    required this.ride,
    required this.meterCents,
    required this.distanceKm,
  });

  final DriverRide ride;
  final int meterCents;
  final double distanceKm;

  @override
  List<Object?> get props => [ride, meterCents, distanceKm];
}

// Mockup screen 7: driving the passenger to their destination.
final class DriverFlowInRide extends DriverFlowState {
  const DriverFlowInRide({required this.ride});

  final DriverRide ride;

  @override
  List<Object?> get props => [ride];
}

// Mockup screen 6: waiting for the passenger and their boarding code.
final class DriverFlowBoarding extends DriverFlowState {
  const DriverFlowBoarding({required this.ride, required this.arrivedAt});

  final DriverRide ride;
  final DateTime arrivedAt;

  @override
  List<Object?> get props => [ride, arrivedAt];
}

// Mockup screen 5: driving to the passenger.
final class DriverFlowPickup extends DriverFlowState {
  const DriverFlowPickup({required this.ride});

  final DriverRide ride;

  @override
  List<Object?> get props => [ride];
}

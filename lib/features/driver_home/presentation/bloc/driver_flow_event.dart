part of 'driver_flow_bloc.dart';

sealed class DriverFlowEvent extends Equatable {
  const DriverFlowEvent();

  @override
  List<Object?> get props => [];
}

// At login, or when the driver taps "Réessayer".
final class DriverFlowStarted extends DriverFlowEvent {
  const DriverFlowStarted();
}

// "Plus tard": only offered while no document blocks driving.
final class DriverDocumentsPostponed extends DriverFlowEvent {
  const DriverDocumentsPostponed();
}

// A ride request was accepted: the driver goes to the passenger.
final class DriverRideAccepted extends DriverFlowEvent {
  const DriverRideAccepted({required this.ride});

  final DriverRide ride;

  @override
  List<Object?> get props => [ride];
}

// "Je suis arrivé".
final class DriverArrivedAtPickup extends DriverFlowEvent {
  const DriverArrivedAtPickup();
}

// The boarding code was correct: the passenger is on board.
final class DriverRideStarted extends DriverFlowEvent {
  const DriverRideStarted();
}

// "Client absent".
final class DriverNoShowReported extends DriverFlowEvent {
  const DriverNoShowReported();
}

// "Terminer la course": the passenger is at their destination.
final class DriverRideFinished extends DriverFlowEvent {
  const DriverRideFinished({
    required this.meterCents,
    required this.distanceKm,
  });

  // The last reading of the taximeter.
  final int meterCents;
  final double distanceKm;

  @override
  List<Object?> get props => [meterCents, distanceKm];
}

// "Valider et repasser libre".
final class DriverRideCompleted extends DriverFlowEvent {
  const DriverRideCompleted();
}

// "Vos documents" in the "Compte" tab.
final class DriverDocumentsOpened extends DriverFlowEvent {
  const DriverDocumentsOpened({required this.documents});

  final DriverDocuments documents;

  @override
  List<Object?> get props => [documents];
}

// "Retour" on the documents opened from the account.
final class DriverDocumentsClosed extends DriverFlowEvent {
  const DriverDocumentsClosed();
}

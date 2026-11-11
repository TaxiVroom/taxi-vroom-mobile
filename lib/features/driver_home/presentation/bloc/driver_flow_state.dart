part of 'driver_flow_bloc.dart';

sealed class DriverFlowState extends Equatable {
  const DriverFlowState();

  @override
  List<Object?> get props => [];
}

// A full-screen loader while the documents are read: at start, or over the
// home when "Passer en ligne" was refused for a document.
final class DriverFlowCheckingDocuments extends DriverFlowState {
  const DriverFlowCheckingDocuments({this.isOverHome = false});

  final bool isOverHome;

  @override
  List<Object?> get props => [isOverHome];
}

final class DriverFlowDocumentsFailure extends DriverFlowState {
  const DriverFlowDocumentsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// A document blocks: opened when "Passer en ligne" is refused. Spec
// taxi-vroom-api/docs/specs/documents-du-chauffeur.md.
final class DriverFlowDocuments extends DriverFlowState {
  const DriverFlowDocuments({
    required this.documents,
    this.isSubmitting = false,
    this.failureMessage,
    this.sendingTypeId,
    this.isRefreshing = false,
  });

  // The document being sent: its card shows a spinner.
  final String? sendingTypeId;

  final DriverDocuments documents;
  final bool isSubmitting;
  final String? failureMessage;

  // Read again after a notification or a return to the app: a loader
  // instead of the old states.
  final bool isRefreshing;

  @override
  List<Object?> get props => [
    documents,
    isSubmitting,
    failureMessage,
    sendingTypeId,
    isRefreshing,
  ];
}

// The documents, opened from the "Compte" tab or the home's banner.
final class DriverFlowDocumentsReview extends DriverFlowState {
  const DriverFlowDocumentsReview({
    required this.documents,
    this.isSubmitting = false,
    this.failureMessage,
    this.sendingTypeId,
    this.isRefreshing = false,
  });

  // The document being sent: its card shows a spinner.
  final String? sendingTypeId;

  final DriverDocuments documents;
  final bool isSubmitting;
  final String? failureMessage;

  // Read again after a notification or a return to the app: a loader
  // instead of the old states.
  final bool isRefreshing;

  @override
  List<Object?> get props => [
    documents,
    isSubmitting,
    failureMessage,
    sendingTypeId,
    isRefreshing,
  ];
}

final class DriverFlowHome extends DriverFlowState {
  const DriverFlowHome({this.notice, this.documents});

  // Why the ride stopped, when the driver did not choose it.
  final String? notice;

  // For the banner: a document to renew or to provide. Null until read.
  final DriverDocuments? documents;

  @override
  List<Object?> get props => [notice, documents];
}

// Mockup screen 8: the meter amount to type, then free again.
final class DriverFlowCheckout extends DriverFlowState {
  const DriverFlowCheckout({required this.ride});

  final DriverRide ride;

  @override
  List<Object?> get props => [ride];
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
  const DriverFlowPickup({
    required this.ride,
    this.isSubmitting = false,
    this.failureMessage,
  });

  final DriverRide ride;

  // "Je suis arrivé" or "Se désister" is being sent.
  final bool isSubmitting;

  final String? failureMessage;

  @override
  List<Object?> get props => [ride, isSubmitting, failureMessage];
}

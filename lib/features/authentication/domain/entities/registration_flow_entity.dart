import 'package:equatable/equatable.dart';

// Dart equivalent of TypeScript's:
//   type RegistrationStep = PassengerRegistrationStep | DriverRegistrationStep
// Both enums implement this interface, making them interchangeable as fromStep
// in RegistrationFlowUpdate without sacrificing enum type safety.
abstract interface class RegistrationStep {
  // Backend UPPER_SNAKE_CASE string for this step — used in PATCH /v1/registration-flows/me.
  String serialize();

  RegistrationStep? get next;

  RegistrationStep? get previous;
}

// Each role gets its own step enum.
// A passenger can never end up on a driver-only step — invalid states are impossible.
enum PassengerRegistrationStep implements RegistrationStep {
  socialLink,
  email,
  name,
  notifications, // last screen, before the registration is finalized
  complete; // registration finalized: the passenger goes straight home

  /// The next data step in the passenger registration flow.
  /// Null when already at the last step.
  PassengerRegistrationStep? get next => switch (this) {
    socialLink => email,
    email => name,
    name => notifications,
    notifications => complete,
    complete => null,
  };

  /// The previous data step in the passenger registration flow.
  /// Null when already at the first step.
  PassengerRegistrationStep? get previous => switch (this) {
    socialLink => null,
    email => socialLink,
    name => email,
    notifications => name,
    complete => notifications,
  };

  @override
  String serialize() => switch (this) {
    socialLink => 'SOCIAL_LINK',
    email => 'EMAIL',
    name => 'NAME',
    notifications => 'NOTIFICATIONS',
    complete => 'COMPLETE',
  };
}

enum DriverRegistrationStep implements RegistrationStep {
  socialLink,
  email,
  name,
  documents, // étape spécifique chauffeur (upload des documents)
  pendingReview, // documents soumis — en attente de validation admin
  documentsCorrection, // admin a rejeté au moins un document — le chauffeur doit corriger
  complete;

  /// Null pour [pendingReview] : la transition suivante est déclenchée par l'admin.
  DriverRegistrationStep? get next => switch (this) {
    socialLink => email,
    email => name,
    name => documents,
    documents => pendingReview,
    pendingReview => null,
    documentsCorrection => pendingReview,
    complete => null,
  };

  DriverRegistrationStep? get previous => switch (this) {
    socialLink => null,
    email => socialLink,
    name => email,
    documents => name,
    pendingReview => null,
    documentsCorrection => name,
    complete => pendingReview,
  };

  @override
  String serialize() => switch (this) {
    socialLink => 'SOCIAL_LINK',
    email => 'EMAIL',
    name => 'NAME',
    documents => 'DOCUMENTS',
    pendingReview => 'PENDING_REVIEW',
    documentsCorrection => 'DOCUMENTS_CORRECTION',
    complete => 'COMPLETE',
  };
}

// Dart's equivalent of a TypeScript discriminated union.
// The compiler knows every possible subtype (PassengerRegistrationFlowEntity,
// DriverRegistrationFlowEntity) and forces you to handle each case in every
// switch — exhaustive at compile time, no runtime surprises.
sealed class RegistrationFlowEntity extends Equatable {
  const RegistrationFlowEntity({
    required this.userId,
    this.email,
    this.firstName,
    this.lastName,
  });

  final String userId;
  final String? email;
  final String? firstName;
  final String? lastName;

  // A finalized registration skips the registration screens entirely.
  bool get isComplete;
}

// Direct subtypes of a sealed class must live in the same file.
// PassengerRegistrationFlowModel (data layer) can remain in its own file —
// only direct subtypes of the sealed class are constrained.
base class PassengerRegistrationFlowEntity extends RegistrationFlowEntity {
  const PassengerRegistrationFlowEntity({
    required super.userId,
    required this.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });

  final PassengerRegistrationStep currentStep;

  @override
  bool get isComplete => currentStep == PassengerRegistrationStep.complete;

  @override
  List<Object?> get props => [userId, currentStep, email, firstName, lastName];
}

base class DriverRegistrationFlowEntity extends RegistrationFlowEntity {
  const DriverRegistrationFlowEntity({
    required super.userId,
    required this.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });

  final DriverRegistrationStep currentStep;

  @override
  bool get isComplete => currentStep == DriverRegistrationStep.complete;

  @override
  List<Object?> get props => [userId, currentStep, email, firstName, lastName];
}

import 'package:equatable/equatable.dart';

// Each role gets its own step enum.
// A passenger can never end up on a driver-only step — invalid states are impossible.
enum PassengerRegistrationStep {
  socialLink,
  email,
  name,
  complete;

  /// The next data step in the passenger registration flow.
  /// Null when already at the last step.
  PassengerRegistrationStep? get next => switch (this) {
        socialLink => email,
        email      => name,
        name       => complete,
        complete   => null,
      };

  /// The previous data step in the passenger registration flow.
  /// Null when already at the first step.
  PassengerRegistrationStep? get previous => switch (this) {
        socialLink => null,
        email      => socialLink,
        name       => email,
        complete   => name,
      };
}
// enum DriverRegistrationStep { email, name, license, vehicleInfo, complete }

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
  List<Object?> get props => [userId, currentStep, email, firstName, lastName];
}

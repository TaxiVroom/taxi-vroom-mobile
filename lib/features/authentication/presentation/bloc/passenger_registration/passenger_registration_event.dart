part of 'passenger_registration_bloc.dart';

sealed class PassengerRegistrationEvent extends Equatable {
  const PassengerRegistrationEvent();

  @override
  List<Object?> get props => [];
}

final class RegGoogleSignInRequested extends PassengerRegistrationEvent {
  const RegGoogleSignInRequested();
}

final class RegEmailOptionSelected extends PassengerRegistrationEvent {
  const RegEmailOptionSelected();
}

final class RegEmailTyped extends PassengerRegistrationEvent {
  const RegEmailTyped({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}

final class RegEmailSubmitted extends PassengerRegistrationEvent {
  const RegEmailSubmitted();
}

final class RegNameFirstNameTyped extends PassengerRegistrationEvent {
  const RegNameFirstNameTyped({required this.firstName});

  final String firstName;

  @override
  List<Object> get props => [firstName];
}

final class RegNameLastNameTyped extends PassengerRegistrationEvent {
  const RegNameLastNameTyped({required this.lastName});

  final String lastName;

  @override
  List<Object> get props => [lastName];
}

final class RegNameSubmitted extends PassengerRegistrationEvent {
  const RegNameSubmitted();
}

/// Événement générique de retour arrière.
/// Le bloc détermine l'étape précédente via [PassengerRegistrationStep.previous].
final class RegBackPressed extends PassengerRegistrationEvent {
  const RegBackPressed();
}

final class RegNotificationPermissionRequested extends PassengerRegistrationEvent {
  const RegNotificationPermissionRequested();
}

final class RegNotificationPermissionSkipped extends PassengerRegistrationEvent {
  const RegNotificationPermissionSkipped();
}

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

final class RegFirstNameTyped extends PassengerRegistrationEvent {
  const RegFirstNameTyped({required this.firstName});

  final String firstName;

  @override
  List<Object> get props => [firstName];
}

final class RegLastNameTyped extends PassengerRegistrationEvent {
  const RegLastNameTyped({required this.lastName});

  final String lastName;

  @override
  List<Object> get props => [lastName];
}

final class RegNameSubmitted extends PassengerRegistrationEvent {
  const RegNameSubmitted();
}

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

import 'package:equatable/equatable.dart';

// Abstract (not sealed) so concrete blocs can define extra events in their own files.
abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

final class RegistrationGoogleSignInRequested extends RegistrationEvent {
  const RegistrationGoogleSignInRequested();
}

final class RegistrationEmailOptionSelected extends RegistrationEvent {
  const RegistrationEmailOptionSelected();
}

final class RegistrationEmailTyped extends RegistrationEvent {
  const RegistrationEmailTyped({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}

final class RegistrationEmailSubmitted extends RegistrationEvent {
  const RegistrationEmailSubmitted();
}

final class RegistrationFirstNameTyped extends RegistrationEvent {
  const RegistrationFirstNameTyped({required this.firstName});

  final String firstName;

  @override
  List<Object> get props => [firstName];
}

final class RegistrationLastNameTyped extends RegistrationEvent {
  const RegistrationLastNameTyped({required this.lastName});

  final String lastName;

  @override
  List<Object> get props => [lastName];
}

final class RegistrationNameSubmitted extends RegistrationEvent {
  const RegistrationNameSubmitted();
}

/// Le bloc détermine l'étape précédente à partir du type de state courant.
final class RegistrationBackPressed extends RegistrationEvent {
  const RegistrationBackPressed();
}

final class RegistrationNotificationPermissionRequested extends RegistrationEvent {
  const RegistrationNotificationPermissionRequested();
}

final class RegistrationNotificationPermissionSkipped extends RegistrationEvent {
  const RegistrationNotificationPermissionSkipped();
}

part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthSessionRestoreRequested extends AuthEvent {
  const AuthSessionRestoreRequested();
}

final class AuthPhoneNumberChanged extends AuthEvent {
  const AuthPhoneNumberChanged({required this.internationalPhoneNumber});

  final String internationalPhoneNumber;

  @override
  List<Object> get props => [internationalPhoneNumber];
}

final class AuthPhoneNumberSubmitted extends AuthEvent {
  const AuthPhoneNumberSubmitted();
}

final class AuthOtpSubmitted extends AuthEvent {
  const AuthOtpSubmitted({required this.otp, required this.phoneNumber});

  final String otp;
  final String phoneNumber;

  @override
  List<Object> get props => [otp, phoneNumber];
}

final class AuthOtpResendRequested extends AuthEvent {
  const AuthOtpResendRequested({required this.phoneNumber});

  final String phoneNumber;

  @override
  List<Object> get props => [phoneNumber];
}

final class AuthOtpTimerTicked extends AuthEvent {
  const AuthOtpTimerTicked({required this.remainingSeconds});

  final int remainingSeconds;

  @override
  List<Object> get props => [remainingSeconds];
}

final class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested({required this.role});

  final UserRole role;

  @override
  List<Object> get props => [role];
}

final class AuthRoleChosen extends AuthEvent {
  const AuthRoleChosen({required this.role});

  final UserRole role;

  @override
  List<Object> get props => [role];
}

final class AuthBackPressed extends AuthEvent {
  const AuthBackPressed();
}

final class AuthRegistrationCompleted extends AuthEvent {
  const AuthRegistrationCompleted();
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

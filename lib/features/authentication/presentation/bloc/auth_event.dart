part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
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
  const AuthGoogleSignInRequested();
}

final class AuthEmailOptionSelected extends AuthEvent {
  const AuthEmailOptionSelected();
}

final class AuthEmailTyped extends AuthEvent {
  const AuthEmailTyped({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}

final class AuthEmailSubmitted extends AuthEvent {
  const AuthEmailSubmitted();
}

final class AuthNameFirstNameTyped extends AuthEvent {
  const AuthNameFirstNameTyped({required this.firstName});

  final String firstName;

  @override
  List<Object> get props => [firstName];
}

final class AuthNameLastNameTyped extends AuthEvent {
  const AuthNameLastNameTyped({required this.lastName});

  final String lastName;

  @override
  List<Object> get props => [lastName];
}

final class AuthNameSubmitted extends AuthEvent {
  const AuthNameSubmitted();
}

final class AuthNotificationPermissionRequested extends AuthEvent {
  const AuthNotificationPermissionRequested();
}

final class AuthNotificationPermissionSkipped extends AuthEvent {
  const AuthNotificationPermissionSkipped();
}

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

/// Dispatché par WelcomePage quand l'utilisateur choisit le tunnel téléphone.
final class AuthPhoneSelected extends AuthEvent {
  const AuthPhoneSelected();
}

/// Dispatché par PhoneNumberPage et OtpVerificationPage via PopScope.
/// Le BLoC détermine l'état précédent selon le state courant.
final class AuthBackPressed extends AuthEvent {
  const AuthBackPressed();
}

/// Dispatché par PassengerRegistrationNavigator via onAuthenticated.
/// Signale que le tunnel d'inscription est terminé — on peut afficher HomePage.
final class AuthRegistrationCompleted extends AuthEvent {
  const AuthRegistrationCompleted();
}

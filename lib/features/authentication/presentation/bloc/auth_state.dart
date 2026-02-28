part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthPhoneNumberInputReady extends AuthState {
  const AuthPhoneNumberInputReady({this.isPhoneValid = false});

  final bool isPhoneValid;

  AuthPhoneNumberInputReady copyWith({bool? isPhoneValid}) =>
      AuthPhoneNumberInputReady(isPhoneValid: isPhoneValid ?? this.isPhoneValid);

  @override
  List<Object> get props => [isPhoneValid];
}

final class AuthPhoneNumberLoading extends AuthState {
  const AuthPhoneNumberLoading();
}

/// Emitted once when the OTP is sent. Triggers navigation to the OTP screen.
final class AuthOtpSent extends AuthState {
  const AuthOtpSent({required this.phoneNumber});

  final String phoneNumber;

  @override
  List<Object> get props => [phoneNumber];
}

/// Emitted on every timer tick. Updates the countdown display on the OTP screen.
final class AuthOtpCountdown extends AuthState {
  const AuthOtpCountdown({
    required this.phoneNumber,
    required this.remainingSeconds,
    required this.isResendAvailable,
  });

  final String phoneNumber;
  final int remainingSeconds;
  final bool isResendAvailable;

  AuthOtpCountdown copyWith({int? remainingSeconds, bool? isResendAvailable}) {
    return AuthOtpCountdown(
      phoneNumber: phoneNumber,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isResendAvailable: isResendAvailable ?? this.isResendAvailable,
    );
  }

  @override
  List<Object> get props => [phoneNumber, remainingSeconds, isResendAvailable];
}

final class AuthOtpVerifying extends AuthState {
  const AuthOtpVerifying({required this.phoneNumber});

  final String phoneNumber;

  @override
  List<Object> get props => [phoneNumber];
}

final class AuthGoogleSignInLoading extends AuthState {
  const AuthGoogleSignInLoading();
}

/// État de sortie du flow auth. Porte le résultat de [getOrCreateRegistrationFlow]
/// afin que le navigator puisse router vers le bon flow d'inscription
/// (passenger, driver…) via un switch exhaustif sur le type de [registrationFlow].
final class AuthOtpVerified extends AuthState {
  const AuthOtpVerified({required this.registrationFlow});

  // Sealed class — le compilateur force la gestion exhaustive de chaque sous-type
  // (PassengerRegistrationFlowEntity, DriverRegistrationFlowEntity…) dans le navigator.
  final RegistrationFlowEntity registrationFlow;

  @override
  List<Object> get props => [registrationFlow];
}

final class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

/// État terminal : inscription terminée, on affiche HomePage.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();
}

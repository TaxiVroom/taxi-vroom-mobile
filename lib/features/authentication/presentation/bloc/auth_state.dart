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

final class AuthNewUserDetected extends AuthState {
  const AuthNewUserDetected({required this.phoneNumber});

  final String phoneNumber;

  @override
  List<Object> get props => [phoneNumber];
}

final class AuthEmailInputReady extends AuthState {
  const AuthEmailInputReady({
    required this.phoneNumber,
    this.isFormatValid = false,
  });

  final String phoneNumber;
  final bool isFormatValid;

  AuthEmailInputReady copyWith({bool? isFormatValid}) => AuthEmailInputReady(
        phoneNumber: phoneNumber,
        isFormatValid: isFormatValid ?? this.isFormatValid,
      );

  @override
  List<Object> get props => [phoneNumber, isFormatValid];
}

final class AuthEmailChecking extends AuthState {
  const AuthEmailChecking();
}

final class AuthEmailTaken extends AuthState {
  const AuthEmailTaken({required this.phoneNumber});

  final String phoneNumber;

  @override
  List<Object> get props => [phoneNumber];
}

final class AuthNameInputReady extends AuthState {
  const AuthNameInputReady({
    required this.phoneNumber,
    required this.email,
    this.isFormValid = false,
  });

  final String phoneNumber;
  final String email;
  final bool isFormValid;

  AuthNameInputReady copyWith({bool? isFormValid}) => AuthNameInputReady(
        phoneNumber: phoneNumber,
        email: email,
        isFormValid: isFormValid ?? this.isFormValid,
      );

  @override
  List<Object> get props => [phoneNumber, email, isFormValid];
}

final class AuthRegistering extends AuthState {
  const AuthRegistering();
}

final class AuthNotificationReady extends AuthState {
  const AuthNotificationReady();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();
}

final class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

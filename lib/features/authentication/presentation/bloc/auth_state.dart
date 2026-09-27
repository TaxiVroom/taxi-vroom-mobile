part of 'auth_bloc.dart';

// ignore_for_file: always_put_required_named_parameters_first

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

// Le rôle est obligatoire et non-nullable sur tous les états post-sélection.
// Accéder à state.role sur un AuthInitial est une erreur de compilation —
// le compilateur garantit que le rôle est présent si l'état est AuthRoleSelectedState.
sealed class AuthRoleSelectedState extends AuthState {
  const AuthRoleSelectedState({
    required this.role,
    this.phoneNumber = '',
  });

  final UserRole role;
  final String phoneNumber;

  @override
  List<Object?> get props => [role, phoneNumber];
}

final class AuthPhoneNumberInputReady extends AuthRoleSelectedState {
  const AuthPhoneNumberInputReady({
    required super.role,
    super.phoneNumber,
    this.isPhoneValid = false,
  });

  final bool isPhoneValid;

  AuthPhoneNumberInputReady copyWith({bool? isPhoneValid}) =>
      AuthPhoneNumberInputReady(
        role: role,
        phoneNumber: phoneNumber,
        isPhoneValid: isPhoneValid ?? this.isPhoneValid,
      );

  @override
  List<Object> get props => [role, phoneNumber, isPhoneValid];
}

final class AuthPhoneNumberLoading extends AuthRoleSelectedState {
  const AuthPhoneNumberLoading({required super.role, super.phoneNumber});
}

final class AuthOtpSent extends AuthRoleSelectedState {
  const AuthOtpSent({required super.role, required super.phoneNumber});
}

final class AuthOtpCountdown extends AuthRoleSelectedState {
  const AuthOtpCountdown({
    required super.role,
    required super.phoneNumber,
    required this.remainingSeconds,
    required this.isResendAvailable,
  });

  final int remainingSeconds;
  final bool isResendAvailable;

  AuthOtpCountdown copyWith({int? remainingSeconds, bool? isResendAvailable}) {
    return AuthOtpCountdown(
      role: role,
      phoneNumber: phoneNumber,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isResendAvailable: isResendAvailable ?? this.isResendAvailable,
    );
  }

  @override
  List<Object> get props => [
    role,
    phoneNumber,
    remainingSeconds,
    isResendAvailable,
  ];
}

final class AuthOtpVerifying extends AuthRoleSelectedState {
  const AuthOtpVerifying({required super.role, required super.phoneNumber});
}

final class AuthGoogleSignInLoading extends AuthRoleSelectedState {
  const AuthGoogleSignInLoading({required super.role});
}

// Sealed class — le compilateur force la gestion exhaustive de chaque sous-type
// (PassengerRegistrationFlowEntity, DriverRegistrationFlowEntity…) dans le navigator.
final class AuthOtpVerified extends AuthRoleSelectedState {
  const AuthOtpVerified({required super.role, required this.registrationFlow});

  final RegistrationFlowEntity registrationFlow;

  @override
  List<Object> get props => [role, registrationFlow];
}

final class AuthError extends AuthRoleSelectedState {
  const AuthError({
    required this.message,
    required super.role,
    super.phoneNumber,
  });

  final String message;

  @override
  List<Object> get props => [role, phoneNumber, message];
}

final class AuthAuthenticated extends AuthRoleSelectedState {
  const AuthAuthenticated({required super.role});
}

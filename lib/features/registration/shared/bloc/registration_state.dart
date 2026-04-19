import 'package:equatable/equatable.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';

// Abstract (not sealed) so concrete blocs can define extra states in their own files.
// currentStep est porté dans le state — comme phoneNumber dans AuthState —
// ce qui permet au bloc de base de piloter la navigation arrière sans hook.
abstract class RegistrationState extends Equatable {
  const RegistrationState({
    required this.currentStep,
    this.email = '',
    this.firstName = '',
    this.lastName = '',
  });

  final RegistrationStep currentStep;
  final String email;
  final String firstName;
  final String lastName;

  @override
  List<Object?> get props => [currentStep, email, firstName, lastName];
}

final class RegistrationSocialLinkReady extends RegistrationState {
  const RegistrationSocialLinkReady({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class RegistrationGoogleSignInLoading extends RegistrationState {
  const RegistrationGoogleSignInLoading({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class RegistrationEmailInputReady extends RegistrationState {
  const RegistrationEmailInputReady({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
    this.isFormatValid = false,
  });

  final bool isFormatValid;

  RegistrationEmailInputReady copyWith({
    String? email,
    String? firstName,
    String? lastName,
    bool? isFormatValid,
  }) =>
      RegistrationEmailInputReady(
        currentStep: currentStep,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        isFormatValid: isFormatValid ?? this.isFormatValid,
      );

  @override
  List<Object?> get props => [currentStep, email, firstName, lastName, isFormatValid];
}

final class RegistrationEmailChecking extends RegistrationState {
  const RegistrationEmailChecking({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class RegistrationEmailTaken extends RegistrationState {
  const RegistrationEmailTaken({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class RegistrationNameInputReady extends RegistrationState {
  const RegistrationNameInputReady({
    required super.currentStep,
    required super.email,
    super.firstName,
    super.lastName,
    this.isFormValid = false,
  });

  final bool isFormValid;

  RegistrationNameInputReady copyWith({
    String? firstName,
    String? lastName,
    bool? isFormValid,
  }) =>
      RegistrationNameInputReady(
        currentStep: currentStep,
        email: email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        isFormValid: isFormValid ?? this.isFormValid,
      );

  @override
  List<Object?> get props => [currentStep, email, firstName, lastName, isFormValid];
}

final class RegistrationRegistering extends RegistrationState {
  const RegistrationRegistering({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class RegistrationNotificationReady extends RegistrationState {
  const RegistrationNotificationReady({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class RegistrationAuthenticated extends RegistrationState {
  const RegistrationAuthenticated({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class RegistrationError extends RegistrationState {
  const RegistrationError({
    required this.message,
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });

  final String message;

  @override
  List<Object?> get props => [currentStep, email, firstName, lastName, message];
}

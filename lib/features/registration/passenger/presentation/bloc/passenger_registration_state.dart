part of 'passenger_registration_bloc.dart';

// currentStep est désormais la boussole portée par chaque état —
// le BLoC n'a plus de variables privées et le State est la seule source de vérité.
// Les données du formulaire (email, firstName, lastName) sont dans la classe de base
// pour être accessibles via state.email sans type-check depuis l'UI.
sealed class PassengerRegistrationState extends Equatable {
  const PassengerRegistrationState({
    required this.currentStep,
    this.email = '',
    this.firstName = '',
    this.lastName = '',
  });

  final PassengerRegistrationStep currentStep;
  final String email;
  final String firstName;
  final String lastName;

  @override
  List<Object?> get props => [currentStep, email, firstName, lastName];
}

final class RegSocialLinkReady extends PassengerRegistrationState {
  const RegSocialLinkReady({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class RegGoogleSignInLoading extends PassengerRegistrationState {
  const RegGoogleSignInLoading({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class RegEmailInputReady extends PassengerRegistrationState {
  const RegEmailInputReady({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
    this.isFormatValid = false,
  });

  final bool isFormatValid;

  RegEmailInputReady copyWith({
    String? email,
    String? firstName,
    String? lastName,
    bool? isFormatValid,
  }) =>
      RegEmailInputReady(
        currentStep: currentStep,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        isFormatValid: isFormatValid ?? this.isFormatValid,
      );

  @override
  List<Object?> get props => [currentStep, email, firstName, lastName, isFormatValid];
}

final class RegEmailChecking extends PassengerRegistrationState {
  const RegEmailChecking({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class RegEmailTaken extends PassengerRegistrationState {
  const RegEmailTaken({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class RegNameInputReady extends PassengerRegistrationState {
  const RegNameInputReady({
    required super.currentStep,
    required super.email,
    super.firstName,
    super.lastName,
    this.isFormValid = false,
  });

  final bool isFormValid;

  RegNameInputReady copyWith({
    String? firstName,
    String? lastName,
    bool? isFormValid,
  }) =>
      RegNameInputReady(
        currentStep: currentStep,
        email: email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        isFormValid: isFormValid ?? this.isFormValid,
      );

  @override
  List<Object?> get props => [currentStep, email, firstName, lastName, isFormValid];
}

final class RegRegistering extends PassengerRegistrationState {
  const RegRegistering({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class RegNotificationReady extends PassengerRegistrationState {
  const RegNotificationReady({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class RegAuthenticated extends PassengerRegistrationState {
  const RegAuthenticated({
    required super.currentStep,
    super.email,
    super.firstName,
    super.lastName,
  });
}

final class RegError extends PassengerRegistrationState {
  const RegError({
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

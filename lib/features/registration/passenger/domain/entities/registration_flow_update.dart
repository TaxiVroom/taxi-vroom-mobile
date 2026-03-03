import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';

// We use a sealed class rather than an object with optional fields
// so that it is impossible to send an empty or inconsistent update.
// Each type contains only the fields it needs.
// fromStep = the step the user is completing (backend sets currentStep to NEXT_STEP[fromStep]).
sealed class RegistrationFlowUpdate {
  const RegistrationFlowUpdate({required this.fromStep});

  final PassengerRegistrationStep fromStep;
}

final class EmailUpdate extends RegistrationFlowUpdate {
  const EmailUpdate({required super.fromStep, required this.email});

  final String email;
}

final class NameUpdate extends RegistrationFlowUpdate {
  const NameUpdate({
    required super.fromStep,
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;
}

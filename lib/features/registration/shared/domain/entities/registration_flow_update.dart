import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';

// We use a sealed class rather than an object with optional fields
// so that it is impossible to send an empty or inconsistent update.
// Each type contains only the fields it needs.
// fromStep = the step the user is completing (backend sets currentStep to NEXT_STEP[fromStep]).
sealed class RegistrationFlowUpdate {
  const RegistrationFlowUpdate({required this.fromStep});

  final RegistrationStep fromStep;
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

// The vehicle was saved by PUT /v1/registration-flows/me/vehicle: the
// documents come next.
final class VehicleConfirmedUpdate extends RegistrationFlowUpdate {
  const VehicleConfirmedUpdate({required super.fromStep});
}

// Notifie le backend que le chauffeur a fini d'uploader ses documents
// et que son dossier est prêt à être reviewé par un admin.
// Pas de champs supplémentaires — fromStep suffit pour que le backend
// passe currentStep à PENDING_REVIEW.
final class DocumentsReadyForReviewUpdate extends RegistrationFlowUpdate {
  const DocumentsReadyForReviewUpdate({required super.fromStep});
}

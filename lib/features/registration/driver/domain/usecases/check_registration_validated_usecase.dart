import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/driver/domain/repositories/driver_registration_repository.dart';

enum RegistrationReview {
  pending,
  validated,
  // A document type was added while the file waited: back to "Mes
  // documents". Spec taxi-vroom-api/docs/specs/documents-du-chauffeur.md,
  // point 6.
  newDocumentAsked,
}

// "Dossier en cours de vérification": whether the admin validated every
// document, so the driver can go to the home. Asked again on each sign: a
// failure only means "not yet". Spec
// taxi-vroom-api/docs/specs/validation-du-dossier.md.
class CheckRegistrationValidatedUseCase {
  const CheckRegistrationValidatedUseCase(this._repository);

  final DriverRegistrationRepository _repository;

  Future<RegistrationReview> call() async => switch (await _repository
      .getCurrentStep()) {
    Ok(value: DriverRegistrationStep.complete) => RegistrationReview.validated,
    Ok(value: DriverRegistrationStep.documents) =>
      RegistrationReview.newDocumentAsked,
    Ok() || Error() => RegistrationReview.pending,
  };
}

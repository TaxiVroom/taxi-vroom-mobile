import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/driver/domain/repositories/driver_registration_repository.dart';

// "Dossier en cours de vérification": whether the admin validated every
// document, so the driver can go to the home. Asked again on each sign: a
// failure only means "not yet". Spec
// taxi-vroom-api/docs/specs/validation-du-dossier.md.
class CheckRegistrationValidatedUseCase {
  const CheckRegistrationValidatedUseCase(this._repository);

  final DriverRegistrationRepository _repository;

  Future<bool> call() async => switch (await _repository.getCurrentStep()) {
    Ok(:final value) => value == DriverRegistrationStep.complete,
    Error() => false,
  };
}

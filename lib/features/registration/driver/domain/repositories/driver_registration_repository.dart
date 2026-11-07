import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/driver/domain/entities/registration_vehicle.dart';
import 'package:mobile/features/registration/shared/domain/repositories/registration_flow_repository.dart';

abstract class DriverRegistrationRepository
    implements RegistrationFlowRepository {
  // "Votre taxi": replaces the vehicle given before, if any.
  Future<Result<void>> saveVehicle(RegistrationVehicle vehicle);

  // The vehicle saved, the documents come next.
  Future<Result<void>> confirmVehicle({required String userId});

  // Where the registration is now, e.g. complete once the admin validated
  // every document.
  Future<Result<DriverRegistrationStep>> getCurrentStep();

  // The phone's notification token while waiting for the admin: the driver
  // is told when their documents are validated. Spec
  // taxi-vroom-api/docs/specs/validation-du-dossier.md.
  Future<Result<void>> savePushToken(String token);
}

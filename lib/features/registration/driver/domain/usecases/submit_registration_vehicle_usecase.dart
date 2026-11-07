import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/registration/driver/domain/entities/registration_vehicle.dart';
import 'package:mobile/features/registration/driver/domain/repositories/driver_registration_repository.dart';

// "Votre taxi", "Continuer": the vehicle is saved, then the documents come
// next. Spec taxi-vroom-api/docs/specs/vehicule-du-chauffeur.md.
class SubmitRegistrationVehicleUseCase {
  const SubmitRegistrationVehicleUseCase(this._repository);

  final DriverRegistrationRepository _repository;

  Future<Result<void>> call({
    required String userId,
    required RegistrationVehicle vehicle,
  }) async {
    if (await _repository.saveVehicle(vehicle) case Error(:final error)) {
      return Result.error(error);
    }
    return _repository.confirmVehicle(userId: userId);
  }
}

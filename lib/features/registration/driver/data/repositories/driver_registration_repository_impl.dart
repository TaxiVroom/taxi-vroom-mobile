import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/driver/data/datasources/driver_registration_remote_datasource.dart';
import 'package:mobile/features/registration/driver/data/models/registration_vehicle_model.dart';
import 'package:mobile/features/registration/driver/domain/entities/registration_vehicle.dart';
import 'package:mobile/features/registration/driver/domain/repositories/driver_registration_repository.dart';
import 'package:mobile/features/registration/shared/domain/entities/registration_flow_update.dart';

class DriverRegistrationRepositoryImpl implements DriverRegistrationRepository {
  const DriverRegistrationRepositoryImpl(this._dataSource);

  final DriverRegistrationRemoteDataSource _dataSource;

  static const _plateInvalid = 'REGISTRATION.VEHICLE_PLATE_INVALID';
  static const _plateTaken = 'REGISTRATION.VEHICLE_PLATE_TAKEN';
  static const _licenceTaken = 'REGISTRATION.VEHICLE_LICENCE_TAKEN';

  @override
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  }) => _dataSource.updateRegistrationFlow(userId: userId, update: update);

  // A plate refused by the API is told as the screen tells it; a plate or a
  // taxi number already taken is told under its field.
  @override
  Future<Result<void>> saveVehicle(RegistrationVehicle vehicle) async {
    try {
      await _dataSource.saveVehicle(
        RegistrationVehicleModel.fromDomain(vehicle),
      );
      return const Result.ok(null);
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map<String, dynamic> ? data['code'] : null;
      return Result.error(switch (code) {
        _plateInvalid => const ValidationFailure('Plaque au format AB-123-CD'),
        _plateTaken => const VehiclePlateTakenFailure(
          'Cette plaque est déjà enregistrée',
        ),
        _licenceTaken => VehicleLicenceTakenFailure(
          'Ce numéro de taxi est déjà enregistré à ${vehicle.communeName}',
        ),
        _ => e.toFailure(),
      });
    }
  }

  @override
  Future<Result<void>> confirmVehicle({required String userId}) async {
    try {
      await _dataSource.updateRegistrationFlow(
        userId: userId,
        update: const VehicleConfirmedUpdate(
          fromStep: DriverRegistrationStep.vehicle,
        ),
      );
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<DriverRegistrationStep>> getCurrentStep() async {
    try {
      final flow = await _dataSource.getRegistrationFlow();
      return Result.ok(flow.currentStep);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<void>> savePushToken(String token) async {
    try {
      await _dataSource.savePushToken(token);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

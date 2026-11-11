import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_activity.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_activity_repository.dart';

// The pill and the three cards of the "Conduire" tab, loaded apart from the
// home: their failure never stops the driver from driving.
class LoadDriverActivityUseCase {
  const LoadDriverActivityUseCase(this._driverActivityRepository);

  final DriverActivityRepository _driverActivityRepository;

  Future<Result<DriverActivity>> call() =>
      _driverActivityRepository.getActivity();
}

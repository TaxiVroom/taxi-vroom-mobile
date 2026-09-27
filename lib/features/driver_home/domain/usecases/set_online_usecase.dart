import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_activity_repository.dart';

// "Passer en ligne" / "Passer hors ligne".
class SetOnlineUseCase {
  const SetOnlineUseCase(this._driverActivityRepository);

  final DriverActivityRepository _driverActivityRepository;

  Future<Result<void>> call({required bool isOnline}) =>
      _driverActivityRepository.setOnline(isOnline: isOnline);
}

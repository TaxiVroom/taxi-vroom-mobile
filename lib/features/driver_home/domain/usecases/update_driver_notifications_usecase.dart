import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_account_repository.dart';

// The "Notifications" switch of the driver's account.
class UpdateDriverNotificationsUseCase {
  const UpdateDriverNotificationsUseCase(this._driverAccountRepository);

  final DriverAccountRepository _driverAccountRepository;

  Future<Result<void>> call({required bool enabled}) =>
      _driverAccountRepository.setNotificationsEnabled(enabled: enabled);
}

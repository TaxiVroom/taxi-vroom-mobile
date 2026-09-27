import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_account.dart';

abstract class DriverAccountRepository {
  Future<Result<DriverAccount>> getAccount();

  Future<Result<void>> setNotificationsEnabled({required bool enabled});
}

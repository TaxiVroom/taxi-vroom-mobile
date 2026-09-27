import 'package:mobile/features/driver_home/data/models/driver_account_model.dart';

// No backend endpoint yet: only the fake implementation exists.
abstract class DriverAccountRemoteDataSource {
  Future<DriverAccountModel> getAccount();

  Future<void> setNotificationsEnabled({required bool enabled});
}

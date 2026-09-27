import 'package:mobile/features/passenger_home/data/models/passenger_account_model.dart';

// No backend endpoint yet: only the fake implementation exists.
abstract class AccountRemoteDataSource {
  Future<PassengerAccountModel> getAccount();

  Future<void> setNotificationsEnabled({required bool enabled});
}

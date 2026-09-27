import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_account.dart';

abstract class AccountRepository {
  Future<Result<PassengerAccount>> getAccount();

  Future<Result<void>> setNotificationsEnabled({required bool enabled});
}

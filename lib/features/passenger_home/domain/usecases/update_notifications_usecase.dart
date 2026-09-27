import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/repositories/account_repository.dart';

class UpdateNotificationsUseCase {
  const UpdateNotificationsUseCase(this._repository);

  final AccountRepository _repository;

  Future<Result<void>> call({required bool enabled}) =>
      _repository.setNotificationsEnabled(enabled: enabled);
}

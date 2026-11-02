import 'package:mobile/core/domain/repositories/push_registration_repository.dart';
import 'package:mobile/core/utils/result.dart';

class UnregisterPushTokenUseCase {
  const UnregisterPushTokenUseCase(this._repository);

  final PushRegistrationRepository _repository;

  Future<Result<void>> call() => _repository.unregister();
}

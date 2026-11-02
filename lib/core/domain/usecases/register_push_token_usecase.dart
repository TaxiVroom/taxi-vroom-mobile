import 'package:mobile/core/domain/repositories/push_registration_repository.dart';
import 'package:mobile/core/utils/result.dart';

class RegisterPushTokenUseCase {
  const RegisterPushTokenUseCase(this._repository);

  final PushRegistrationRepository _repository;

  Future<Result<void>> call() => _repository.register();
}

import 'package:mobile/core/domain/repositories/push_registration_repository.dart';
import 'package:mobile/core/utils/result.dart';

// Keeps the backend up to date when Firebase replaces the phone's token.
class WatchPushTokenRefreshUseCase {
  const WatchPushTokenRefreshUseCase(this._repository);

  final PushRegistrationRepository _repository;

  Stream<Result<void>> call() => _repository.watchTokenRefresh();
}

import 'package:mobile/core/domain/repositories/notification_permission_repository.dart';
import 'package:mobile/core/utils/result.dart';

// "Réglages": the app's page in the phone's settings, the only way left once
// the notifications are permanently denied.
class OpenNotificationSettingsUseCase {
  const OpenNotificationSettingsUseCase(this._repository);

  final NotificationPermissionRepository _repository;

  Future<Result<void>> call() => _repository.openSettings();
}

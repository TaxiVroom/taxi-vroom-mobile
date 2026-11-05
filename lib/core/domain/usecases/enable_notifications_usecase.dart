import 'package:mobile/core/domain/entities/notification_permission.dart';
import 'package:mobile/core/domain/repositories/notification_permission_repository.dart';
import 'package:mobile/core/domain/usecases/ensure_notification_permission_usecase.dart';
import 'package:mobile/core/utils/result.dart';

// "Activer" in the account tab: the person asked for it, so when the system
// no longer shows its dialog, the phone's settings open at once.
class EnableNotificationsUseCase {
  const EnableNotificationsUseCase(this._repository);

  final NotificationPermissionRepository _repository;

  Future<Result<NotificationPermission>> call() async {
    final result = await EnsureNotificationPermissionUseCase(_repository)();
    if (result case Ok(:final value) when value.needsSettings) {
      await _repository.openSettings();
    }
    return result;
  }
}

import 'package:mobile/core/domain/entities/notification_permission.dart';
import 'package:mobile/core/domain/repositories/notification_permission_repository.dart';
import 'package:mobile/core/utils/result.dart';

// After an action that needs notifications: asks the phone for them if they
// are not allowed yet. permanentlyDenied means only the settings can allow
// them now, which the screen tells. Spec permission-notifications.md.
class EnsureNotificationPermissionUseCase {
  const EnsureNotificationPermissionUseCase(this._repository);

  final NotificationPermissionRepository _repository;

  Future<Result<NotificationPermission>> call() async {
    final status = await _repository.getStatus();
    return switch (status) {
      Ok(value: NotificationPermission.granted) || Error() => status,
      // Asking again is cheap: when blocked, the phone answers at once,
      // without a dialog.
      Ok() => _repository.request(),
    };
  }
}

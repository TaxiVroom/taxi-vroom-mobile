import 'package:mobile/core/domain/entities/notification_permission.dart';
import 'package:mobile/core/domain/repositories/notification_permission_repository.dart';
import 'package:mobile/core/utils/result.dart';

// Whether the phone shows the app's notifications, without asking anything:
// for the account tab. On Android, "denied" also covers a permanent denial.
class LoadNotificationPermissionUseCase {
  const LoadNotificationPermissionUseCase(this._repository);

  final NotificationPermissionRepository _repository;

  Future<Result<NotificationPermission>> call() => _repository.getStatus();
}

import 'package:mobile/core/domain/entities/notification_permission.dart';
import 'package:mobile/core/utils/result.dart';

abstract class NotificationPermissionRepository {
  // Never permanentlyDenied on Android: only request() can tell it.
  Future<Result<NotificationPermission>> getStatus();

  // Shows the system dialog when it still can; otherwise answers at once.
  Future<Result<NotificationPermission>> request();

  // The app's page in the phone's settings, the only way left once
  // permanently denied.
  Future<Result<void>> openSettings();
}

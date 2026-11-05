import 'package:flutter/services.dart' show PlatformException;
import 'package:mobile/core/domain/entities/notification_permission.dart';
import 'package:mobile/core/domain/repositories/notification_permission_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:permission_handler/permission_handler.dart';

// On Android, "only the result of request() can be permanentlyDenied; status
// reports denied instead", and a blocked request is answered "immediately
// without showing a dialog". iOS needs PERMISSION_NOTIFICATIONS=1 in the
// Podfile, see the spec permission-notifications.md.
// Docs: https://pub.dev/packages/permission_handler/versions/12.0.1 and
// https://github.com/Baseflow/flutter-permission-handler/blob/main/permission_handler/README.md
class NotificationPermissionRepositoryImpl
    implements NotificationPermissionRepository {
  const NotificationPermissionRepositoryImpl();

  static const _unknown = PermissionFailure(
    'Impossible de vérifier les notifications.',
  );

  @override
  Future<Result<NotificationPermission>> getStatus() =>
      _read(() => Permission.notification.status);

  @override
  Future<Result<NotificationPermission>> request() =>
      _read(() => Permission.notification.request());

  @override
  Future<Result<void>> openSettings() async {
    try {
      await openAppSettings();
      return const Result.ok(null);
    } on PlatformException {
      return const Result.error(_unknown);
    }
  }

  Future<Result<NotificationPermission>> _read(
    Future<PermissionStatus> Function() read,
  ) async {
    try {
      return Result.ok(_toDomain(await read()));
    } on PlatformException {
      return const Result.error(_unknown);
    }
  }

  // Provisional and limited still show notifications (iOS). Restricted, set
  // by parental controls, is changed in the settings only.
  NotificationPermission _toDomain(PermissionStatus status) => switch (status) {
    PermissionStatus.granted ||
    PermissionStatus.limited ||
    PermissionStatus.provisional => NotificationPermission.granted,
    PermissionStatus.denied => NotificationPermission.denied,
    PermissionStatus.permanentlyDenied ||
    PermissionStatus.restricted => NotificationPermission.permanentlyDenied,
  };
}

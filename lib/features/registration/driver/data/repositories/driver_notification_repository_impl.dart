import 'package:mobile/features/registration/driver/domain/repositories/driver_notification_repository.dart';
import 'package:permission_handler/permission_handler.dart';

/// Mock — sera remplacé par Firebase Messaging ou autre
class DriverNotificationRepositoryImpl implements DriverNotificationRepository {
  @override
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}

import 'package:mobile/features/authentication/domain/repositories/notification_repository.dart';
import 'package:permission_handler/permission_handler.dart';

/// Mock — sera remplacé par Firebase Messaging ou autre
class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}

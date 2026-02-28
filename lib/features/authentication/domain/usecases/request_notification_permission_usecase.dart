import 'package:mobile/features/authentication/domain/repositories/notification_repository.dart';

class RequestNotificationPermissionUseCase {
  const RequestNotificationPermissionUseCase(this._repository);

  final NotificationRepository _repository;

  Future<bool> call() => _repository.requestPermission();
}

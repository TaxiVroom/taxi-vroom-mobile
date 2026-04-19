import 'package:mobile/features/registration/driver/domain/repositories/driver_notification_repository.dart';

class RequestDriverNotificationPermissionUseCase {
  const RequestDriverNotificationPermissionUseCase(this._repository);

  final DriverNotificationRepository _repository;

  Future<bool> call() => _repository.requestPermission();
}

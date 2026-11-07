import 'package:mobile/core/domain/repositories/push_registration_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/registration/driver/domain/repositories/driver_registration_repository.dart';

// The waiting driver allowed the notifications: their phone's token goes to
// the registration, so the backend can tell them when their documents are
// validated. Firebase asks for the permission first ("before FCM payloads can
// be received on your device, you must first ask the user's permission"):
// called once it is granted. Spec
// taxi-vroom-api/docs/specs/validation-du-dossier.md.
class SendRegistrationPushTokenUseCase {
  const SendRegistrationPushTokenUseCase({
    required PushRegistrationRepository pushRegistrationRepository,
    required DriverRegistrationRepository driverRegistrationRepository,
  }) : _pushRegistrationRepository = pushRegistrationRepository,
       _driverRegistrationRepository = driverRegistrationRepository;

  final PushRegistrationRepository _pushRegistrationRepository;
  final DriverRegistrationRepository _driverRegistrationRepository;

  // No token from Firebase: nothing to send, and nothing to tell.
  Future<Result<void>> call() async {
    switch (await _pushRegistrationRepository.getDeviceToken()) {
      case Ok(value: final token?):
        return _driverRegistrationRepository.savePushToken(token);
      case Ok():
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }
}

import 'package:mobile/core/domain/repositories/push_registration_repository.dart';

// The ride of each notification received while the app is on screen, which
// the system does not show, or touched while the app was in background.
// The screen opens that ride, or looks again at what changed when the
// notification is about no ride (null).
class WatchPushedRidesUseCase {
  const WatchPushedRidesUseCase(this._repository);

  final PushRegistrationRepository _repository;

  Stream<String?> call() => _repository.watchPushedRides();
}

import 'package:mobile/core/utils/result.dart';

abstract class PushRegistrationRepository {
  // Tells the backend this phone is the user's.
  Future<Result<void>> register();

  // Sends the new token each time Firebase replaces it, while listened to.
  Stream<Result<void>> watchTokenRefresh();

  // Stops the notifications on this phone. Before signing out: it needs the
  // user's session.
  Future<Result<void>> unregister();
}

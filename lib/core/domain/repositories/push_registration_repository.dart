import 'package:mobile/core/utils/result.dart';

abstract class PushRegistrationRepository {
  // Tells the backend this phone is the user's.
  Future<Result<void>> register();

  // The phone's notification token, null when Firebase gives none; for a
  // registration still waiting for its account.
  Future<Result<String?>> getDeviceToken();

  // Sends the new token each time Firebase replaces it, while listened to.
  Stream<Result<void>> watchTokenRefresh();

  // The ride of each message received while the app is on screen, or of a
  // notification touched while it was in background: news about a ride the
  // screen may not show yet. Null for a message about no ride.
  Stream<String?> watchPushedRides();

  // The ride of the notification that launched the app, if one did. Given
  // once.
  Future<String?> getLaunchRideId();

  // Stops the notifications on this phone. Before signing out: it needs the
  // user's session.
  Future<Result<void>> unregister();
}

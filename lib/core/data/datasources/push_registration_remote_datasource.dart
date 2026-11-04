import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class PushRegistrationRemoteDataSource {
  // Null when the device has no token yet.
  Future<String?> getDeviceToken();

  Stream<String> get tokenRefreshes;

  // The ride of each message received while the app is on screen, which
  // the system does not show; null for a message about no ride.
  Stream<String?> get foregroundRideIds;

  // The ride of each notification touched while the app was in background.
  Stream<String?> get openedRideIds;

  // The ride of the notification that launched the app, once.
  Future<String?> getLaunchRideId();

  Future<void> saveToken(String token);

  Future<void> deleteToken();
}

// The token comes from Firebase Cloud Messaging; the backend keeps it to reach
// this phone.
// Docs: https://firebase.google.com/docs/cloud-messaging/flutter/get-started
class PushRegistrationRemoteDataSourceImpl
    implements PushRegistrationRemoteDataSource {
  const PushRegistrationRemoteDataSourceImpl(this._messaging, this._dio);

  static const _path = '/v1/me/push-registration';

  final FirebaseMessaging _messaging;
  final Dio _dio;

  @override
  Future<String?> getDeviceToken() => _messaging.getToken();

  @override
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  // The backend puts the ride's id in the message's data.
  static const _rideIdKey = 'rideId';

  // https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages
  @override
  Stream<String?> get foregroundRideIds =>
      FirebaseMessaging.onMessage.map(_rideId);

  @override
  Stream<String?> get openedRideIds =>
      FirebaseMessaging.onMessageOpenedApp.map(_rideId);

  // Removed once read, says the doc: later calls give null.
  @override
  Future<String?> getLaunchRideId() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _rideId(message);
  }

  String? _rideId(RemoteMessage message) => message.data[_rideIdKey] as String?;

  @override
  Future<void> saveToken(String token) =>
      _dio.put<void>(_path, data: {'token': token});

  @override
  Future<void> deleteToken() => _dio.delete<void>(_path);
}

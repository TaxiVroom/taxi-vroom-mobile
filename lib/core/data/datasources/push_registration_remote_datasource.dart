import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class PushRegistrationRemoteDataSource {
  // Null when the device has no token yet.
  Future<String?> getDeviceToken();

  Stream<String> get tokenRefreshes;

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

  @override
  Future<void> saveToken(String token) =>
      _dio.put<void>(_path, data: {'token': token});

  @override
  Future<void> deleteToken() => _dio.delete<void>(_path);
}

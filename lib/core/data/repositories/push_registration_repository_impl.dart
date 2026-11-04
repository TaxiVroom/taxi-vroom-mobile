import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/core/data/datasources/push_registration_remote_datasource.dart';
import 'package:mobile/core/domain/repositories/push_registration_repository.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:stream_transform/stream_transform.dart';

class PushRegistrationRepositoryImpl implements PushRegistrationRepository {
  const PushRegistrationRepositoryImpl(this._dataSource);

  // Signing out must not hang without a connection.
  static const _unregisterTimeout = Duration(seconds: 5);

  final PushRegistrationRemoteDataSource _dataSource;

  @override
  Future<Result<void>> register() => _send(() async {
    final token = await _dataSource.getDeviceToken();
    if (token != null) await _dataSource.saveToken(token);
  });

  @override
  Stream<Result<void>> watchTokenRefresh() => _dataSource.tokenRefreshes
      .asyncMap((token) => _send(() => _dataSource.saveToken(token)));

  @override
  Stream<String?> watchPushedRides() =>
      _dataSource.foregroundRideIds.merge(_dataSource.openedRideIds);

  // No ride to open when Firebase cannot tell: the app starts as usual.
  @override
  Future<String?> getLaunchRideId() async {
    try {
      return await _dataSource.getLaunchRideId();
    } on FirebaseException {
      return null;
    }
  }

  Future<Result<void>> _send(Future<void> Function() request) async {
    try {
      await request();
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    } on FirebaseException catch (e) {
      return Result.error(
        ServerFailure(e.message ?? 'Notifications indisponibles.'),
      );
    }
  }

  @override
  Future<Result<void>> unregister() async {
    try {
      await _dataSource.deleteToken().timeout(_unregisterTimeout);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    } on TimeoutException {
      return const Result.error(NetworkFailure('Connexion impossible'));
    }
  }
}

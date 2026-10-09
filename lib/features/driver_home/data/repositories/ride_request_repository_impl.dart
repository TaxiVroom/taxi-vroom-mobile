import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/ride_request_remote_datasource.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_request.dart';
import 'package:mobile/features/driver_home/domain/repositories/ride_request_repository.dart';

class RideRequestRepositoryImpl implements RideRequestRepository {
  const RideRequestRepositoryImpl(this._dataSource);

  final RideRequestRemoteDataSource _dataSource;

  // Answered too late: expired, so already proposed to another driver.
  static const _noLongerOffered = ServerFailure(
    'Cette course n’est plus disponible.',
  );

  // Not an async* with await for: its cancel would wait for the next request,
  // which may never come.
  @override
  Stream<Result<RideRequest?>> watchRideRequests({
    required Coordinates around,
  }) => _dataSource
      .watchRideRequests(
        latitude: around.latitude,
        longitude: around.longitude,
      )
      .transform(
        StreamTransformer.fromHandlers(
          handleData: (model, sink) => sink.add(Result.ok(model?.toDomain())),
          handleError: (error, stackTrace, sink) => switch (error) {
            FirebaseException() => sink.add(Result.error(_toFailure(error))),
            _ => sink.addError(error, stackTrace),
          },
        ),
      );

  @override
  Future<Result<DriverRide>> acceptRideRequest(String requestId) async {
    try {
      final model = await _dataSource.acceptRideRequest(requestId);
      return Result.ok(model.toDomain());
    } on DioException catch (e) {
      return Result.error(_answerFailure(e));
    } on FirebaseException catch (e) {
      return Result.error(_toFailure(e));
    }
  }

  @override
  Future<Result<void>> declineRideRequest(String requestId) async {
    try {
      await _dataSource.declineRideRequest(requestId);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(_answerFailure(e));
    }
  }

  Failure _answerFailure(DioException e) =>
      e.response?.statusCode == 409 ? _noLongerOffered : e.toFailure();

  Failure _toFailure(FirebaseException e) =>
      ServerFailure(e.message ?? 'Connexion au service impossible.');
}

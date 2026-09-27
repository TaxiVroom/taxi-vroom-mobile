import 'package:dio/dio.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/ride_request_remote_datasource.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_request.dart';
import 'package:mobile/features/driver_home/domain/repositories/ride_request_repository.dart';

class RideRequestRepositoryImpl implements RideRequestRepository {
  const RideRequestRepositoryImpl(this._dataSource);

  final RideRequestRemoteDataSource _dataSource;

  @override
  Stream<Result<RideRequest>> watchRideRequests({
    required Coordinates around,
  }) async* {
    try {
      final requests = _dataSource.watchRideRequests(
        latitude: around.latitude,
        longitude: around.longitude,
      );
      await for (final model in requests) {
        yield Result.ok(model.toDomain());
      }
    } on DioException catch (e) {
      yield Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<DriverRide>> acceptRideRequest(String requestId) async {
    try {
      final model = await _dataSource.acceptRideRequest(requestId);
      return Result.ok(model.toDomain());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<void>> declineRideRequest(String requestId) async {
    try {
      await _dataSource.declineRideRequest(requestId);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

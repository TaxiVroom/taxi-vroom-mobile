import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_ride_remote_datasource.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

class DriverRideRepositoryImpl implements DriverRideRepository {
  const DriverRideRepositoryImpl(this._dataSource);

  final DriverRideRemoteDataSource _dataSource;

  @override
  Future<Result<bool>> verifyBoardingCode({
    required String rideId,
    required String code,
  }) async {
    try {
      return Result.ok(
        await _dataSource.verifyBoardingCode(rideId: rideId, code: code),
      );
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<void>> startRide(String rideId) async {
    try {
      await _dataSource.startRide(rideId);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<void>> reportNoShow(String rideId) async {
    try {
      await _dataSource.reportNoShow(rideId);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<RideCheckout>> getCheckout({
    required String rideId,
    required int meterCents,
  }) async {
    try {
      final model = await _dataSource.getCheckout(rideId);
      return Result.ok(model.toDomain(meterCents: meterCents));
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<void>> completeRide({
    required String rideId,
    required RideCheckout checkout,
    required int customerRating,
  }) async {
    try {
      await _dataSource.completeRide(
        rideId: rideId,
        meterCents: checkout.meterCents,
        supplementCounts: checkout.supplementCounts,
        totalCents: checkout.totalCents,
        customerRating: customerRating,
      );
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

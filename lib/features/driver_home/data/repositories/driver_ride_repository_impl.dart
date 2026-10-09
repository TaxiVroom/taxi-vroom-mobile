import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_ride_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/datasources/ride_checkout_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/models/ride_start_model.dart';
import 'package:mobile/features/driver_home/domain/entities/fare_supplement.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_start.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

class DriverRideRepositoryImpl implements DriverRideRepository {
  const DriverRideRepositoryImpl(this._dataSource, this._checkoutDataSource);

  final DriverRideRemoteDataSource _dataSource;

  // No backend yet: simulated.
  final RideCheckoutRemoteDataSource _checkoutDataSource;

  // The statuses where the ride is still the driver's, before the passenger
  // got in or during the ride.
  static const _activeStatuses = {
    'DRIVER_EN_ROUTE',
    'DRIVER_ARRIVED',
    'IN_PROGRESS',
  };

  // The app keeps the button off until then: only a wrong clock gets here.
  static const _noShowTooEarly = ValidationFailure(
    'Attendez 5 minutes après votre arrivée pour signaler le client absent.',
  );

  @override
  Future<Result<void>> arriveAtPickup(String rideId) =>
      _send(() => _dataSource.arriveAtPickup(rideId));

  @override
  Future<Result<RideStart>> startRide({
    required String rideId,
    required String boardingCode,
  }) async {
    try {
      final model = await _dataSource.startRide(
        rideId: rideId,
        boardingCode: boardingCode,
      );
      return Result.ok(model.toDomain());
    } on DioException catch (e) {
      final response = e.response;
      // A refused code: its body tells why.
      if (response?.statusCode == 422) {
        final data = response!.data as Map<String, dynamic>;
        return Result.ok(RideStartModel.fromJson(data).toDomain());
      }
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<void>> reportNoShow(String rideId) async {
    try {
      await _dataSource.reportNoShow(rideId);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(
        e.response?.statusCode == 422 ? _noShowTooEarly : e.toFailure(),
      );
    }
  }

  @override
  Future<Result<void>> withdrawFromRide(String rideId) =>
      _send(() => _dataSource.withdrawFromRide(rideId));

  // Ends at the first status where the ride is no longer the driver's: a
  // cancellation, or the end of the ride. A lost connection only means the
  // driver is not told.
  @override
  Stream<void> watchPassengerCancellation(String rideId) => _dataSource
      .watchRideStatus(rideId)
      .where((status) => !_activeStatuses.contains(status))
      .take(1)
      .where((status) => status == 'CANCELLED')
      .handleError((Object _) {});

  @override
  Future<Result<RideCheckout>> getCheckout(String rideId) async {
    try {
      final model = await _checkoutDataSource.getCheckout(rideId);
      return Result.ok(model.toDomain());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<void>> completeRide({
    required String rideId,
    required int meterCents,
    required List<(FareSupplement, int)> supplements,
    required int customerRating,
  }) => _send(() async {
    await _dataSource.completeRide(
      rideId: rideId,
      meterCents: meterCents,
      supplements: [
        for (final (supplement, count) in supplements)
          (
            supplementId: supplement.id,
            label: supplement.label,
            unitPriceCents: supplement.amountCents,
            quantity: count,
          ),
      ],
    );
    await _checkoutDataSource.rateCustomer(
      rideId: rideId,
      rating: customerRating,
    );
  });

  Future<Result<void>> _send(Future<void> Function() request) async {
    try {
      await request();
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

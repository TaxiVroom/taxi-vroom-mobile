import 'package:dio/dio.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/data/datasources/ride_remote_datasource.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_history.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

class RideRepositoryImpl implements RideRepository {
  const RideRepositoryImpl(this._dataSource);

  final RideRemoteDataSource _dataSource;

  @override
  Future<Result<String>> requestRide({
    required Coordinates origin,
    required Place destination,
    required String offerId,
  }) async {
    try {
      final rideId = await _dataSource.requestRide(
        originLatitude: origin.latitude,
        originLongitude: origin.longitude,
        destinationLatitude: destination.coordinates.latitude,
        destinationLongitude: destination.coordinates.longitude,
        destinationName: destination.name,
        offerId: offerId,
      );
      return Result.ok(rideId);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Stream<Result<Ride>> watchRide(String rideId) async* {
    try {
      await for (final model in _dataSource.watchRide(rideId)) {
        yield Result.ok(model.toDomain());
      }
    } on DioException catch (e) {
      yield Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<void>> cancelRide(String rideId) async {
    try {
      await _dataSource.cancelRide(rideId);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<String>> bookRide({
    required Coordinates origin,
    required Place destination,
    required TaxiOffer offer,
    required DateTime scheduledPickup,
  }) async {
    try {
      final bookingId = await _dataSource.bookRide(
        originLatitude: origin.latitude,
        originLongitude: origin.longitude,
        destinationLatitude: destination.coordinates.latitude,
        destinationLongitude: destination.coordinates.longitude,
        destinationName: destination.name,
        offerId: offer.id,
        offerName: offer.name,
        minPriceCents: offer.minPriceCents,
        maxPriceCents: offer.maxPriceCents,
        scheduledPickup: scheduledPickup,
      );
      return Result.ok(bookingId);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<void>> cancelBooking(String bookingId) async {
    try {
      await _dataSource.cancelBooking(bookingId);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<RideHistory>> getRideHistory() async {
    try {
      final model = await _dataSource.getRideHistory();
      return Result.ok(model.toDomain());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<void>> rateRide({
    required String rideId,
    required int stars,
    required List<String> compliments,
    required int tipCents,
  }) async {
    try {
      await _dataSource.rateRide(
        rideId: rideId,
        stars: stars,
        compliments: compliments,
        tipCents: tipCents,
      );
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

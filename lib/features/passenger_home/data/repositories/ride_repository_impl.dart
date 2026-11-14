import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/core/domain/entities/paged_list.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/data/datasources/ride_booking_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/ride_remote_datasource.dart';
import 'package:mobile/features/passenger_home/domain/entities/booked_ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/past_ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_compliment.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

class RideRepositoryImpl implements RideRepository {
  const RideRepositoryImpl(this._dataSource, this._bookingDataSource);

  final RideRemoteDataSource _dataSource;

  final RideBookingRemoteDataSource _bookingDataSource;

  // The passenger got in meanwhile, or the ride already stopped.
  static const _tooLateToCancel = ValidationFailure(
    'La course ne peut plus être annulée.',
  );

  // The only 422 of the order and the booking (RIDE.ESTIMATE_EXPIRED in the
  // API).
  static const _estimateExpired = EstimateExpiredFailure(
    'Le prix a été mis à jour : vérifiez-le avant de commander.',
  );

  // The only 400 of the booking (RIDE.PICKUP_TIME_NOT_BOOKABLE): the pickup
  // got too close while the passenger looked at the price.
  static const _pickupTimeNotBookable = ValidationFailure(
    'Cet horaire ne peut plus être réservé, choisissez-en un autre.',
  );

  @override
  Future<Result<String>> requestRide(TaxiOffer offer) async {
    try {
      await _dataSource.requestRide(offer.rideId);
      return Result.ok(offer.rideId);
    } on DioException catch (e) {
      return Result.error(
        e.response?.statusCode == 422 ? _estimateExpired : e.toFailure(),
      );
    }
  }

  @override
  Future<Result<String?>> getCurrentRideId() async {
    try {
      return Result.ok(await _dataSource.getCurrentRideId());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  // Not an async* with await for: its cancel would wait for the next update,
  // which does not come while the taxi is stopped.
  @override
  Stream<Result<Ride>> watchRide(String rideId) => _dataSource
      .watchRide(rideId)
      .transform(
        StreamTransformer.fromHandlers(
          handleData: (model, sink) => sink.add(Result.ok(model.toDomain())),
          handleError: (error, stackTrace, sink) => switch (error) {
            FirebaseException(:final message) => sink.add(
              Result.error(
                ServerFailure(message ?? 'Connexion au service impossible.'),
              ),
            ),
            // The boarding code comes from the API.
            DioException() => sink.add(Result.error(error.toFailure())),
            _ => sink.addError(error, stackTrace),
          },
        ),
      );

  @override
  Future<Result<void>> cancelRide(String rideId) async {
    try {
      await _dataSource.cancelRide(rideId);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(
        e.response?.statusCode == 409 ? _tooLateToCancel : e.toFailure(),
      );
    }
  }

  @override
  Future<Result<String>> bookRide(TaxiOffer offer) async {
    try {
      await _bookingDataSource.bookRide(offer.rideId);
      return Result.ok(offer.rideId);
    } on DioException catch (e) {
      return Result.error(switch (e.response?.statusCode) {
        422 => _estimateExpired,
        400 => _pickupTimeNotBookable,
        _ => e.toFailure(),
      });
    }
  }

  @override
  Future<Result<void>> cancelBooking(String bookingId) async {
    try {
      await _bookingDataSource.cancelBooking(bookingId);
      return const Result.ok(null);
    } on DioException catch (e) {
      // A 409: the booking changed meanwhile, e.g. it already started.
      return Result.error(
        e.response?.statusCode == 409
            ? const ValidationFailure(
                'Cette réservation a déjà commencé ou a été annulée.',
              )
            : e.toFailure(),
      );
    }
  }

  @override
  Future<Result<PagedList<BookedRide>>> getBookings({
    required int page,
  }) async {
    try {
      final bookings = await _bookingDataSource.getBookings(page: page);
      return Result.ok(bookings.toDomain((ride) => ride.toDomain()));
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<PagedList<PastRide>>> getPastRides({
    required int page,
  }) async {
    try {
      final pastRides = await _dataSource.getPastRides(page: page);
      return Result.ok(pastRides.toDomain((ride) => ride.toDomain()));
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<void>> rateRide({
    required String rideId,
    required int stars,
    required List<RideCompliment> compliments,
  }) async {
    try {
      await _dataSource.rateRide(
        rideId: rideId,
        stars: stars,
        compliments: [for (final compliment in compliments) compliment.code],
      );
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

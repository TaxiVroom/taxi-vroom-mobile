import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/data/datasources/ride_booking_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/ride_rating_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/ride_remote_datasource.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_history.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

class RideRepositoryImpl implements RideRepository {
  const RideRepositoryImpl(
    this._dataSource,
    this._bookingDataSource,
    this._ratingDataSource,
  );

  final RideRemoteDataSource _dataSource;

  // No backend yet: simulated.
  final RideBookingRemoteDataSource _bookingDataSource;
  final RideRatingRemoteDataSource _ratingDataSource;

  // The passenger got in meanwhile, or the ride already stopped.
  static const _tooLateToCancel = ValidationFailure(
    'La course ne peut plus être annulée.',
  );

  // The only 422 of the order (RIDE.ESTIMATE_EXPIRED in the API).
  static const _estimateExpired = EstimateExpiredFailure(
    'Le prix a été mis à jour : vérifiez-le avant de commander.',
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
  Future<Result<String>> bookRide({
    required Coordinates origin,
    required Place destination,
    required TaxiOffer offer,
    required DateTime scheduledPickup,
  }) async {
    try {
      final bookingId = await _bookingDataSource.bookRide(
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
      await _bookingDataSource.cancelBooking(bookingId);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<RideHistory>> getRideHistory() async {
    try {
      final model = await _bookingDataSource.getRideHistory();
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
  }) async {
    try {
      await _ratingDataSource.rateRide(
        rideId: rideId,
        stars: stars,
        compliments: compliments,
      );
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

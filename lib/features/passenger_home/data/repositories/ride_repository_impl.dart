import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/errors/failures.dart';
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
    required TaxiOffer offer,
  }) async {
    try {
      final rideId = await _dataSource.requestRide(
        originLatitude: origin.latitude,
        originLongitude: origin.longitude,
        destinationLatitude: destination.coordinates.latitude,
        destinationLongitude: destination.coordinates.longitude,
        destinationName: destination.name,
        minPriceCents: offer.minPriceCents,
        maxPriceCents: offer.maxPriceCents,
      );
      return Result.ok(rideId);
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

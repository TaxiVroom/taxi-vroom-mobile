import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_booking_remote_datasource.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_bookings.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_booking_repository.dart';

class DriverBookingRepositoryImpl implements DriverBookingRepository {
  const DriverBookingRepositoryImpl(this._dataSource);

  final DriverBookingRemoteDataSource _dataSource;

  // The server's 409 codes on "Accepter" and "Je pars" (see the API's
  // ride.errors.ts).
  static const _refusals = {
    'RIDE.DRIVER_BUSY': ValidationFailure(
      'Terminez d’abord votre course en cours.',
    ),
    'RIDE.BOOKING_TAKEN': ValidationFailure(
      'Un autre chauffeur a pris cette réservation.',
    ),
    'RIDE.BOOKING_OVERLAP': ValidationFailure(
      'Vous avez déjà une réservation à moins d’une heure de celle-ci.',
    ),
  };

  static const _notAvailable = ValidationFailure(
    'Cette réservation n’est plus disponible.',
  );

  @override
  Future<Result<List<DriverBooking>>> getAcceptedBookings() async {
    try {
      final models = await _dataSource.getAcceptedBookings();
      return Result.ok(models.map((m) => m.toDomain()).toList());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<DriverBookings>> getBookings({
    required Coordinates around,
  }) async {
    try {
      final available = await _dataSource.getAvailableBookings(
        latitude: around.latitude,
        longitude: around.longitude,
      );
      final accepted = await _dataSource.getAcceptedBookings();
      return Result.ok(
        DriverBookings(
          available: available.map((m) => m.toDomain()).toList(),
          accepted: accepted.map((m) => m.toDomain()).toList(),
        ),
      );
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<void>> acceptBooking(String bookingId) async {
    try {
      await _dataSource.acceptBooking(bookingId);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(_refusal(e) ?? e.toFailure());
    }
  }

  @override
  Future<Result<DriverRide>> departForBooking(String bookingId) async {
    try {
      final model = await _dataSource.departForBooking(bookingId);
      return Result.ok(model.toDomain());
    } on DioException catch (e) {
      return Result.error(_refusal(e) ?? e.toFailure());
    } on FirebaseException catch (e) {
      return Result.error(
        ServerFailure(e.message ?? 'Connexion au service impossible.'),
      );
    }
  }

  @override
  Future<Result<void>> withdrawFromBooking(String bookingId) =>
      _sendAnswer(() => _dataSource.withdrawFromBooking(bookingId));

  @override
  Future<Result<void>> refuseBooking(String bookingId) =>
      _sendAnswer(() => _dataSource.refuseBooking(bookingId));

  // A 409: the booking started or was cancelled meanwhile.
  Future<Result<void>> _sendAnswer(Future<void> Function() send) async {
    try {
      await send();
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(
        e.response?.statusCode == 409 ? _notAvailable : e.toFailure(),
      );
    }
  }

  // Any other 409: the booking started or was cancelled meanwhile.
  Failure? _refusal(DioException e) {
    final response = e.response;
    if (response?.statusCode != 409) return null;
    final data = response!.data;
    final code = data is Map<String, dynamic> ? data['code'] : null;
    return _refusals[code] ?? _notAvailable;
  }
}

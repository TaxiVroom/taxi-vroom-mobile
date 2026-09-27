import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_booking_remote_datasource.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_bookings.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_booking_repository.dart';

class DriverBookingRepositoryImpl implements DriverBookingRepository {
  const DriverBookingRepositoryImpl(this._dataSource);

  final DriverBookingRemoteDataSource _dataSource;

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
  Future<Result<DriverBookings>> getBookings() async {
    try {
      final available = await _dataSource.getAvailableBookings();
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
      return Result.error(e.toFailure());
    }
  }
}

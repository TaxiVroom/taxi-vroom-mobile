import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_bookings.dart';

abstract class DriverBookingRepository {
  // Sorted by pickup time, the next one first.
  Future<Result<List<DriverBooking>>> getAcceptedBookings();

  Future<Result<DriverBookings>> getBookings();

  // The booking leaves the available ones for the accepted ones.
  Future<Result<void>> acceptBooking(String bookingId);
}

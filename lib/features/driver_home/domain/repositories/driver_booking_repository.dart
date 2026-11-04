import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_bookings.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';

abstract class DriverBookingRepository {
  // Sorted by pickup time, the next one first.
  Future<Result<List<DriverBooking>>> getAcceptedBookings();

  // The available ones are around the driver's position.
  Future<Result<DriverBookings>> getBookings({required Coordinates around});

  // The booking leaves the available ones for the accepted ones.
  Future<Result<void>> acceptBooking(String bookingId);

  // The booking goes back to the available ones, for the other drivers.
  Future<Result<void>> withdrawFromBooking(String bookingId);

  // The booking leaves this driver's available ones, for good.
  Future<Result<void>> refuseBooking(String bookingId);

  // "Je pars": the ride the driver now drives to.
  Future<Result<DriverRide>> departForBooking(String bookingId);
}

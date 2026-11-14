import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/paged_list.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';

abstract class DriverBookingRepository {
  // One page, sorted by pickup time, the next one first. The first page is 0.
  Future<Result<PagedList<DriverBooking>>> getAcceptedBookings({
    required int page,
  });

  // One page, the available ones around the driver's position, sorted by
  // pickup time.
  Future<Result<PagedList<DriverBooking>>> getAvailableBookings({
    required Coordinates around,
    required int page,
  });

  // The booking leaves the available ones for the accepted ones.
  Future<Result<void>> acceptBooking(String bookingId);

  // The booking goes back to the available ones, for the other drivers.
  Future<Result<void>> withdrawFromBooking(String bookingId);

  // The booking leaves this driver's available ones, for good.
  Future<Result<void>> refuseBooking(String bookingId);

  // "Je pars": the ride the driver now drives to.
  Future<Result<DriverRide>> departForBooking(String bookingId);
}

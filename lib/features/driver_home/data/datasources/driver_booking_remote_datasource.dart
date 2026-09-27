import 'package:mobile/features/driver_home/data/models/driver_booking_model.dart';

// No backend endpoint yet: only the fake implementation exists.
abstract class DriverBookingRemoteDataSource {
  Future<List<DriverBookingModel>> getAcceptedBookings();

  Future<List<DriverBookingModel>> getAvailableBookings();

  Future<void> acceptBooking(String bookingId);
}

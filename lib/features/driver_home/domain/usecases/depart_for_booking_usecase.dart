import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_booking_repository.dart';

// "Je pars" on a booking whose deadline passed: the driver leaves for the
// passenger, as after an accepted offer.
class DepartForBookingUseCase {
  const DepartForBookingUseCase(this._driverBookingRepository);

  final DriverBookingRepository _driverBookingRepository;

  Future<Result<DriverRide>> call(String bookingId) =>
      _driverBookingRepository.departForBooking(bookingId);
}

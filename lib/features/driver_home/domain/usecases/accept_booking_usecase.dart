import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_booking_repository.dart';

// "Accepter" on a booking: the driver commits to the ride in advance.
class AcceptBookingUseCase {
  const AcceptBookingUseCase(this._driverBookingRepository);

  final DriverBookingRepository _driverBookingRepository;

  Future<Result<void>> call(String bookingId) =>
      _driverBookingRepository.acceptBooking(bookingId);
}

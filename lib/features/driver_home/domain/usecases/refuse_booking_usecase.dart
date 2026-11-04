import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_booking_repository.dart';

// "Refuser" on an available booking: it leaves the driver's list for good,
// and nobody else is told.
class RefuseBookingUseCase {
  const RefuseBookingUseCase(this._driverBookingRepository);

  final DriverBookingRepository _driverBookingRepository;

  Future<Result<void>> call(String bookingId) =>
      _driverBookingRepository.refuseBooking(bookingId);
}

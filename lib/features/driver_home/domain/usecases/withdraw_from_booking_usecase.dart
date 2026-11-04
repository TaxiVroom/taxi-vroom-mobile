import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_booking_repository.dart';

// "Se désister" from an accepted booking, before it starts.
class WithdrawFromBookingUseCase {
  const WithdrawFromBookingUseCase(this._driverBookingRepository);

  final DriverBookingRepository _driverBookingRepository;

  Future<Result<void>> call(String bookingId) =>
      _driverBookingRepository.withdrawFromBooking(bookingId);
}

import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_bookings.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_booking_repository.dart';

// The "Réservations" tab.
class LoadDriverBookingsUseCase {
  const LoadDriverBookingsUseCase(this._driverBookingRepository);

  final DriverBookingRepository _driverBookingRepository;

  Future<Result<DriverBookings>> call() =>
      _driverBookingRepository.getBookings();
}

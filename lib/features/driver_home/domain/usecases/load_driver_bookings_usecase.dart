import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_bookings.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_booking_repository.dart';

// The "Réservations" tab: the bookings around the driver, and theirs.
class LoadDriverBookingsUseCase {
  const LoadDriverBookingsUseCase({
    required DriverBookingRepository driverBookingRepository,
    required LocationRepository locationRepository,
  }) : _driverBookingRepository = driverBookingRepository,
       _locationRepository = locationRepository;

  final DriverBookingRepository _driverBookingRepository;
  final LocationRepository _locationRepository;

  Future<Result<DriverBookings>> call() async {
    switch (await _locationRepository.getCurrentPosition()) {
      case Ok(:final value):
        return _driverBookingRepository.getBookings(around: value);
      case Error(:final error):
        return Result.error(error);
    }
  }
}

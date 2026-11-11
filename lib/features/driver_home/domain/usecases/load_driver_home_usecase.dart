import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_home.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_booking_repository.dart';

// Loads the driver home: the driver's position first, then what depends on it.
// The figures load apart (LoadDriverActivityUseCase).
class LoadDriverHomeUseCase {
  const LoadDriverHomeUseCase({
    required LocationRepository locationRepository,
    required DriverBookingRepository driverBookingRepository,
  }) : _locationRepository = locationRepository,
       _driverBookingRepository = driverBookingRepository;

  final LocationRepository _locationRepository;
  final DriverBookingRepository _driverBookingRepository;

  Future<Result<DriverHome>> call() async {
    final Coordinates position;
    switch (await _locationRepository.getCurrentPosition()) {
      case Ok(:final value):
        position = value;
      case Error(:final error):
        return Result.error(error);
    }

    final List<DriverBooking> bookings;
    switch (await _driverBookingRepository.getAcceptedBookings()) {
      case Ok(:final value):
        bookings = value;
      case Error(:final error):
        return Result.error(error);
    }

    return Result.ok(
      DriverHome(position: position, nextBooking: bookings.firstOrNull),
    );
  }
}

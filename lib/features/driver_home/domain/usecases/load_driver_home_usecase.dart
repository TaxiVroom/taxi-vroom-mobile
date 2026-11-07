import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_activity.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_home.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_activity_repository.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_booking_repository.dart';

// Loads the driver home: the driver's position first, then what depends on it.
class LoadDriverHomeUseCase {
  const LoadDriverHomeUseCase({
    required LocationRepository locationRepository,
    required DriverActivityRepository driverActivityRepository,
    required DriverBookingRepository driverBookingRepository,
  }) : _locationRepository = locationRepository,
       _driverActivityRepository = driverActivityRepository,
       _driverBookingRepository = driverBookingRepository;

  final LocationRepository _locationRepository;
  final DriverActivityRepository _driverActivityRepository;
  final DriverBookingRepository _driverBookingRepository;

  Future<Result<DriverHome>> call() async {
    final Coordinates position;
    switch (await _locationRepository.getCurrentPosition()) {
      case Ok(:final value):
        position = value;
      case Error(:final error):
        return Result.error(error);
    }

    final DriverActivity activity;
    switch (await _driverActivityRepository.getActivity()) {
      case Ok(:final value):
        activity = value;
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
      DriverHome(
        position: position,
        activity: activity,
        nextBooking: bookings.firstOrNull,
      ),
    );
  }
}

import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/available_bookings.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_booking_repository.dart';

// The first page of "Disponibles": the bookings around the driver, read from
// the position of the phone.
class LoadAvailableBookingsUseCase {
  const LoadAvailableBookingsUseCase({
    required DriverBookingRepository driverBookingRepository,
    required LocationRepository locationRepository,
  }) : _driverBookingRepository = driverBookingRepository,
       _locationRepository = locationRepository;

  final DriverBookingRepository _driverBookingRepository;
  final LocationRepository _locationRepository;

  Future<Result<AvailableBookings>> call() async {
    switch (await _locationRepository.getCurrentPosition()) {
      case Ok(:final value):
        final around = value;
        return switch (await _driverBookingRepository.getAvailableBookings(
          around: around,
          page: 0,
        )) {
          Ok(:final value) => Result.ok(
            AvailableBookings(around: around, bookings: value),
          ),
          Error(:final error) => Result.error(error),
        };
      case Error(:final error):
        return Result.error(error);
    }
  }
}

import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_home.dart';

// Loads the driver home: the driver's position. The figures load apart
// (LoadDriverActivityUseCase); the bookings only in their tab, never on the
// "Conduire" tab (user's request, 2026-11-11).
class LoadDriverHomeUseCase {
  const LoadDriverHomeUseCase({required LocationRepository locationRepository})
    : _locationRepository = locationRepository;

  final LocationRepository _locationRepository;

  Future<Result<DriverHome>> call() async =>
      switch (await _locationRepository.getCurrentPosition()) {
        Ok(:final value) => Result.ok(DriverHome(position: value)),
        Error(:final error) => Result.error(error),
      };
}

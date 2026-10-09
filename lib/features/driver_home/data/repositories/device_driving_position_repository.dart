import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driving_position_repository.dart';

// The driver's real position, from the device GPS: the one passengers see.
class DeviceDrivingPositionRepository implements DrivingPositionRepository {
  const DeviceDrivingPositionRepository(this._locationRepository);

  final LocationRepository _locationRepository;

  // The route is not needed: the driver follows it, or not.
  @override
  Stream<Result<Coordinates>> watchPosition({
    required List<Coordinates> along,
  }) => _locationRepository.watchPosition();
}

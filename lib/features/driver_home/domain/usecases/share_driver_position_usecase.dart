import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_presence_repository.dart';
import 'package:stream_transform/stream_transform.dart';

// While the driver is online: sends their position as they move, at most
// every 3 seconds, so passengers see the taxi move without wasting battery,
// data or database downloads.
class ShareDriverPositionUseCase {
  const ShareDriverPositionUseCase({
    required LocationRepository locationRepository,
    required DriverPresenceRepository driverPresenceRepository,
  }) : _locationRepository = locationRepository,
       _driverPresenceRepository = driverPresenceRepository;

  static const sharingInterval = Duration(seconds: 3);

  // Below this, a move is GPS noise: a parked taxi sends nothing.
  static const minMoveMeters = 10.0;

  final LocationRepository _locationRepository;
  final DriverPresenceRepository _driverPresenceRepository;

  // Listen while online, cancel when going offline.
  Stream<Result<void>> call() {
    Coordinates? lastMove;
    return _locationRepository
        .watchPosition()
        .where((result) {
          if (result case Ok(:final value)) {
            final from = lastMove;
            if (from != null && from.distanceTo(value) < minMoveMeters) {
              return false;
            }
            lastMove = value;
          }
          return true;
        })
        // The latest position of each period is kept, not dropped.
        .throttle(sharingInterval, trailing: true)
        .asyncMap(
          (result) async => switch (result) {
            Ok(:final value) => _driverPresenceRepository.updatePosition(value),
            Error(:final error) => Result<void>.error(error),
          },
        );
  }
}

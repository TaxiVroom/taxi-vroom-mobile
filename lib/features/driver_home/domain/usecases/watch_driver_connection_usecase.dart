import 'package:mobile/features/driver_home/domain/repositories/driver_presence_repository.dart';

// While the driver is online: whether passengers can still see them, or the
// connection is lost and the driver must be warned.
class WatchDriverConnectionUseCase {
  const WatchDriverConnectionUseCase({
    required DriverPresenceRepository driverPresenceRepository,
  }) : _driverPresenceRepository = driverPresenceRepository;

  final DriverPresenceRepository _driverPresenceRepository;

  Stream<bool> call() => _driverPresenceRepository.watchConnection();
}

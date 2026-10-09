import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

// The passenger may cancel while the driver comes or waits: the driver is
// then free again.
class WatchPassengerCancellationUseCase {
  const WatchPassengerCancellationUseCase(this._driverRideRepository);

  final DriverRideRepository _driverRideRepository;

  Stream<void> call(String rideId) =>
      _driverRideRepository.watchPassengerCancellation(rideId);
}

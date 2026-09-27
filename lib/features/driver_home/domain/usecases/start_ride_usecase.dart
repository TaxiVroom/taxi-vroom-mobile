import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

// "Démarrer la course", once the boarding code is correct.
class StartRideUseCase {
  const StartRideUseCase(this._driverRideRepository);

  final DriverRideRepository _driverRideRepository;

  Future<Result<void>> call(String rideId) =>
      _driverRideRepository.startRide(rideId);
}

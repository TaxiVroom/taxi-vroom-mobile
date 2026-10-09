import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

// "Je suis arrivé": the waiting time starts, and the passenger is told.
class ArriveAtPickupUseCase {
  const ArriveAtPickupUseCase(this._driverRideRepository);

  final DriverRideRepository _driverRideRepository;

  Future<Result<void>> call(String rideId) =>
      _driverRideRepository.arriveAtPickup(rideId);
}

import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

// "Se désister": the ride goes to another driver, never back to this one.
// Also the way out when the boarding code is locked.
class WithdrawFromRideUseCase {
  const WithdrawFromRideUseCase(this._driverRideRepository);

  final DriverRideRepository _driverRideRepository;

  Future<Result<void>> call(String rideId) =>
      _driverRideRepository.withdrawFromRide(rideId);
}

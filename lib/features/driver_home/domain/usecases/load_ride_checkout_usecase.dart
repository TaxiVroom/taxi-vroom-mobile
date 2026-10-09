import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

// The end of ride screen: the driver then types the meter amount.
class LoadRideCheckoutUseCase {
  const LoadRideCheckoutUseCase(this._driverRideRepository);

  final DriverRideRepository _driverRideRepository;

  Future<Result<RideCheckout>> call(String rideId) =>
      _driverRideRepository.getCheckout(rideId);
}

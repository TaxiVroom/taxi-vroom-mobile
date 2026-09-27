import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

// The end of ride screen, from the last amount read on the meter.
class LoadRideCheckoutUseCase {
  const LoadRideCheckoutUseCase(this._driverRideRepository);

  final DriverRideRepository _driverRideRepository;

  Future<Result<RideCheckout>> call({
    required String rideId,
    required int meterCents,
  }) => _driverRideRepository.getCheckout(
    rideId: rideId,
    meterCents: meterCents,
  );
}

import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

// "Valider et repasser libre": the amount is confirmed, the passenger rated.
class CompleteRideUseCase {
  const CompleteRideUseCase(this._driverRideRepository);

  final DriverRideRepository _driverRideRepository;

  Future<Result<void>> call({
    required String rideId,
    required RideCheckout checkout,
    required int customerRating,
  }) => _driverRideRepository.completeRide(
    rideId: rideId,
    checkout: checkout,
    customerRating: customerRating,
  );
}

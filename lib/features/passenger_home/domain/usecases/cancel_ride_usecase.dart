import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

class CancelRideUseCase {
  const CancelRideUseCase(this._repository);

  final RideRepository _repository;

  Future<Result<void>> call(String rideId) => _repository.cancelRide(rideId);
}

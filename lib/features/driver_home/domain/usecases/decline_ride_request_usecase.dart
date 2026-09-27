import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/ride_request_repository.dart';

// "Refuser": the request goes to another driver.
class DeclineRideRequestUseCase {
  const DeclineRideRequestUseCase(this._rideRequestRepository);

  final RideRequestRepository _rideRequestRepository;

  Future<Result<void>> call(String requestId) =>
      _rideRequestRepository.declineRideRequest(requestId);
}

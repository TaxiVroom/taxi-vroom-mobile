import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/repositories/ride_request_repository.dart';

// "Accepter la course": the request becomes the driver's ride.
class AcceptRideRequestUseCase {
  const AcceptRideRequestUseCase(this._rideRequestRepository);

  final RideRequestRepository _rideRequestRepository;

  Future<Result<DriverRide>> call(String requestId) =>
      _rideRequestRepository.acceptRideRequest(requestId);
}

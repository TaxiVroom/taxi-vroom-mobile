import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_request.dart';

abstract class RideRequestRepository {
  // The requests offered to the driver while they are online.
  Stream<Result<RideRequest>> watchRideRequests({
    required Coordinates around,
  });

  // The accepted request becomes a ride.
  Future<Result<DriverRide>> acceptRideRequest(String requestId);

  Future<Result<void>> declineRideRequest(String requestId);
}

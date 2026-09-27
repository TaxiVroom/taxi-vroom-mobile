import 'package:mobile/features/driver_home/data/models/driver_ride_model.dart';
import 'package:mobile/features/driver_home/data/models/ride_request_model.dart';

// No backend endpoint yet: only the fake implementation exists.
abstract class RideRequestRemoteDataSource {
  Stream<RideRequestModel> watchRideRequests({
    required double latitude,
    required double longitude,
  });

  Future<DriverRideModel> acceptRideRequest(String requestId);

  Future<void> declineRideRequest(String requestId);
}

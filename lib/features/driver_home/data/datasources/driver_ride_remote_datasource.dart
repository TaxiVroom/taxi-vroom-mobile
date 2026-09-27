import 'package:mobile/features/driver_home/data/models/ride_checkout_model.dart';

// No backend endpoint yet: only the fake implementation exists.
abstract class DriverRideRemoteDataSource {
  Future<bool> verifyBoardingCode({
    required String rideId,
    required String code,
  });

  Future<void> startRide(String rideId);

  Future<void> reportNoShow(String rideId);

  Future<RideCheckoutModel> getCheckout(String rideId);

  Future<void> completeRide({
    required String rideId,
    required int meterCents,
    required Map<String, int> supplementCounts,
    required int totalCents,
    required int customerRating,
  });
}

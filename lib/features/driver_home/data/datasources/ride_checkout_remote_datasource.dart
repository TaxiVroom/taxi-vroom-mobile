import 'package:mobile/features/driver_home/data/models/ride_checkout_model.dart';

// The end of ride screen. No backend endpoint yet: the supplements depend on
// the city's fare rules, and the ratings are not built. Only the fake
// implementation exists.
abstract class RideCheckoutRemoteDataSource {
  Future<RideCheckoutModel> getCheckout(String rideId);

  // [rating] is 0 when not rated.
  Future<void> rateCustomer({required String rideId, required int rating});
}

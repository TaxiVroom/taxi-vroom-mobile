// The passenger's rating of a ride. No backend endpoint yet: only the fake
// implementation exists.
abstract class RideRatingRemoteDataSource {
  Future<void> rateRide({
    required String rideId,
    required int stars,
    required List<String> compliments,
  });
}

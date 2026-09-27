import 'package:mobile/features/passenger_home/data/models/ride_history_model.dart';
import 'package:mobile/features/passenger_home/data/models/ride_model.dart';

// No backend endpoint yet: only the fake implementation exists.
abstract class RideRemoteDataSource {
  Future<String> requestRide({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationName,
    required String offerId,
  });

  Stream<RideModel> watchRide(String rideId);

  Future<void> cancelRide(String rideId);

  Future<void> rateRide({
    required String rideId,
    required int stars,
    required List<String> compliments,
    required int tipCents,
  });

  Future<String> bookRide({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationName,
    required String offerId,
    required String offerName,
    required int minPriceCents,
    required int maxPriceCents,
    required DateTime scheduledPickup,
  });

  Future<void> cancelBooking(String bookingId);

  Future<RideHistoryModel> getRideHistory();
}

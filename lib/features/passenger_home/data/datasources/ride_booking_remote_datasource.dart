import 'package:mobile/features/passenger_home/data/models/ride_history_model.dart';

// Rides booked in advance and the past rides. No backend endpoint yet: only
// the fake implementation exists.
abstract class RideBookingRemoteDataSource {
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

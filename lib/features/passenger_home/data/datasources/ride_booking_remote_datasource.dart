import 'package:mobile/features/passenger_home/data/models/booked_ride_model.dart';

// Rides booked in advance. No backend endpoint yet: only the fake
// implementation exists.
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

  // Soonest first.
  Future<List<BookedRideModel>> getBookings();
}

import 'package:mobile/core/domain/entities/paged_list.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/booked_ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/past_ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_compliment.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';

abstract class RideRepository {
  // Returns the id of the created ride. The offer's estimate goes with it: the
  // real price comes from the meter.
  // Orders the estimated ride of the offer, at its price. Fails with
  // EstimateExpiredFailure when the price is too old.
  Future<Result<String>> requestRide(TaxiOffer offer);

  // The ride to come back to when the app starts: null without one.
  Future<Result<String?>> getCurrentRideId();

  // Emits the ride every time its status or position changes.
  Stream<Result<Ride>> watchRide(String rideId);

  Future<Result<void>> cancelRide(String rideId);

  Future<Result<void>> rateRide({
    required String rideId,
    required int stars,
    required List<RideCompliment> compliments,
  });

  // Books the offer priced for later, at its price. Returns the id of the
  // booking. Fails with EstimateExpiredFailure when the price is too old.
  Future<Result<String>> bookRide(TaxiOffer offer);

  Future<Result<void>> cancelBooking(String bookingId);

  // One page of the booked rides, the soonest first. The first page is 0.
  Future<Result<PagedList<BookedRide>>> getBookings({required int page});

  // One page of the finished rides, the most recent first.
  Future<Result<PagedList<PastRide>>> getPastRides({required int page});
}

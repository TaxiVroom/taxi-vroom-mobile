import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_compliment.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_history.dart';
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

  Future<Result<RideHistory>> getRideHistory();
}

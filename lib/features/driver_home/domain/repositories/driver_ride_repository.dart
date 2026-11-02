import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/current_driver_ride.dart';
import 'package:mobile/features/driver_home/domain/entities/fare_supplement.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_start.dart';

abstract class DriverRideRepository {
  // The ride to come back to when the app starts: null without one.
  Future<Result<CurrentDriverRide?>> getCurrentRide();

  // "Je suis arrivé": the passenger is told their taxi waits.
  Future<Result<void>> arriveAtPickup(String rideId);

  // "Démarrer la course": checked by the server, the driver never knows the
  // passenger's code.
  Future<Result<RideStart>> startRide({
    required String rideId,
    required String boardingCode,
  });

  // "Client absent": the passenger never came.
  Future<Result<void>> reportNoShow(String rideId);

  // The driver gives the ride up before the passenger got in: it goes to
  // another driver.
  Future<Result<void>> withdrawFromRide(String rideId);

  // Emits once if the passenger cancels, while the driver comes or waits.
  Stream<void> watchPassengerCancellation(String rideId);

  // The end of the ride: the supplements allowed and how the passenger pays.
  // The meter amount is still to be typed.
  Future<Result<RideCheckout>> getCheckout(String rideId);

  // "Valider et repasser libre". [customerRating] is 0 when not rated.
  Future<Result<void>> completeRide({
    required String rideId,
    required int meterCents,
    required List<(FareSupplement, int)> supplements,
    required int customerRating,
  });
}

import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';

abstract class DriverRideRepository {
  // Checked by the server: the driver never knows the passenger's code.
  Future<Result<bool>> verifyBoardingCode({
    required String rideId,
    required String code,
  });

  // "Démarrer la course": the passenger is on board.
  Future<Result<void>> startRide(String rideId);

  // "Client absent": the passenger never came.
  Future<Result<void>> reportNoShow(String rideId);

  // The end of the ride, starting from the meter amount: the supplements
  // allowed and how the passenger pays.
  Future<Result<RideCheckout>> getCheckout({
    required String rideId,
    required int meterCents,
  });

  // "Valider et repasser libre". [customerRating] is 0 when not rated.
  Future<Result<void>> completeRide({
    required String rideId,
    required RideCheckout checkout,
    required int customerRating,
  });
}

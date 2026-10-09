import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_start.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

// "Démarrer la course": the passenger shows a code in their app; the driver
// types it to be sure the right person gets in.
class StartRideUseCase {
  const StartRideUseCase(this._driverRideRepository);

  static const codeLength = 4;

  final DriverRideRepository _driverRideRepository;

  Future<Result<RideStart>> call({
    required String rideId,
    required String boardingCode,
  }) async {
    final result = await _driverRideRepository.startRide(
      rideId: rideId,
      boardingCode: boardingCode,
    );
    return switch (result) {
      // The last wrong code already locks the start: no need to try once more
      // to be told.
      Ok(value: RideStartWrongCode(attemptsLeft: 0)) => const Result.ok(
        RideStartLocked(),
      ),
      _ => result,
    };
  }
}

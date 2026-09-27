import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

// The passenger shows a code in their app; the driver types it to be sure
// the right person gets in.
class VerifyBoardingCodeUseCase {
  const VerifyBoardingCodeUseCase(this._driverRideRepository);

  static const codeLength = 4;

  final DriverRideRepository _driverRideRepository;

  Future<Result<bool>> call({required String rideId, required String code}) =>
      _driverRideRepository.verifyBoardingCode(rideId: rideId, code: code);
}

import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

// "Client absent": the ride ends without the passenger.
class ReportNoShowUseCase {
  const ReportNoShowUseCase(this._driverRideRepository);

  final DriverRideRepository _driverRideRepository;

  Future<Result<void>> call(String rideId) =>
      _driverRideRepository.reportNoShow(rideId);
}

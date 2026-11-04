import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

// "Client absent": the ride ends without the passenger.
class ReportNoShowUseCase {
  const ReportNoShowUseCase(this._driverRideRepository);

  // The wait at the pickup, from the driver's arrival. The server checks it
  // too.
  static const wait = Duration(minutes: 5);

  final DriverRideRepository _driverRideRepository;

  static bool canReport({required Duration waited}) => waited >= wait;

  // Until [canReport]: never below zero.
  static Duration waitLeft({required Duration waited}) =>
      waited >= wait ? Duration.zero : wait - waited;

  Future<Result<void>> call(String rideId) =>
      _driverRideRepository.reportNoShow(rideId);
}

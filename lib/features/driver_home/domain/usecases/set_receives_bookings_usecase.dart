import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_activity_repository.dart';

// "Recevoir les réservations" switch.
class SetReceivesBookingsUseCase {
  const SetReceivesBookingsUseCase(this._driverActivityRepository);

  final DriverActivityRepository _driverActivityRepository;

  Future<Result<void>> call({required bool receivesBookings}) =>
      _driverActivityRepository.setReceivesBookings(
        receivesBookings: receivesBookings,
      );
}

import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/current_driver_ride.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_ride_repository.dart';

class LoadCurrentDriverRideUseCase {
  const LoadCurrentDriverRideUseCase(this._repository);

  final DriverRideRepository _repository;

  Future<Result<CurrentDriverRide?>> call() => _repository.getCurrentRide();
}

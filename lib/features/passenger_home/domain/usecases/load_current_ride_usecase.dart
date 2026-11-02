import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

// The ride to come back to when the app starts: null without one.
class LoadCurrentRideUseCase {
  const LoadCurrentRideUseCase(this._repository);

  final RideRepository _repository;

  Future<Result<String?>> call() => _repository.getCurrentRideId();
}

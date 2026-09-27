import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_history.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

class LoadRideHistoryUseCase {
  const LoadRideHistoryUseCase(this._repository);

  final RideRepository _repository;

  Future<Result<RideHistory>> call() => _repository.getRideHistory();
}

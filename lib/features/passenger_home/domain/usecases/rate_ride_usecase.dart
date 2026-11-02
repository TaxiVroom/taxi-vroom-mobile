import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_compliment.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

class RateRideUseCase {
  const RateRideUseCase(this._repository);

  final RideRepository _repository;

  // No star means the passenger did not rate the ride.
  Future<Result<void>> call({
    required String rideId,
    required int stars,
    required List<RideCompliment> compliments,
  }) async {
    if (stars == 0) return const Result.ok(null);
    return _repository.rateRide(
      rideId: rideId,
      stars: stars,
      compliments: compliments,
    );
  }
}

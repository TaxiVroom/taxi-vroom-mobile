import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

class RateRideUseCase {
  const RateRideUseCase(this._repository);

  final RideRepository _repository;

  Future<Result<void>> call({
    required String rideId,
    required int stars,
    required List<String> compliments,
    required int tipCents,
  }) => _repository.rateRide(
    rideId: rideId,
    stars: stars,
    compliments: compliments,
    tipCents: tipCents,
  );
}

import 'package:mobile/core/domain/entities/paged_list.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/past_ride.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

// One page of "Passées" in "Mes courses".
class LoadPastRidesUseCase {
  const LoadPastRidesUseCase(this._repository);

  final RideRepository _repository;

  Future<Result<PagedList<PastRide>>> call({required int page}) =>
      _repository.getPastRides(page: page);
}

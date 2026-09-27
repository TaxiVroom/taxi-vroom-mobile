import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/route_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_days_usecase.dart';

// "Arriver à" : finds the pickup time needed to arrive on time, with the
// usual traffic at that time of day.
class GetPickupForArrivalUseCase {
  const GetPickupForArrivalUseCase(this._routeRepository);

  final RouteRepository _routeRepository;

  Future<Result<DateTime>> call({
    required Coordinates from,
    required Coordinates to,
    required DateTime arrival,
    required DateTime now,
  }) async {
    switch (await _routeRepository.getRoute(
      from: from,
      to: to,
      arriveBy: arrival,
    )) {
      case Ok(:final value):
        final pickup = value.pickupForArrival(arrival);
        if (!GetPickupDaysUseCase.isBookable(pickup, now: now)) {
          return const Result.error(
            ValidationFailure(
              'Trop tôt pour arriver à cette heure, choisissez plus tard.',
            ),
          );
        }
        return Result.ok(pickup);
      case Error(:final error):
        return Result.error(error);
    }
  }
}

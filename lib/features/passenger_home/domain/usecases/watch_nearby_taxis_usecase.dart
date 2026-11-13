import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';
import 'package:mobile/features/passenger_home/domain/repositories/nearby_taxi_repository.dart';
import 'package:stream_transform/stream_transform.dart';

// The free taxis the passenger can order, closest first, again each time one
// of them moves. The search follows the passenger once they moved away.
class WatchNearbyTaxisUseCase {
  const WatchNearbyTaxisUseCase({
    required NearbyTaxiRepository nearbyTaxiRepository,
    required LocationRepository locationRepository,
  }) : _nearbyTaxiRepository = nearbyTaxiRepository,
       _locationRepository = locationRepository;

  static const reachableRadiusMeters = 5000.0;

  // 10 % of the radius: a new search on each GPS position would download the
  // taxis around again every few seconds, for almost the same ones.
  static const recenterDistanceMeters = 500.0;

  final NearbyTaxiRepository _nearbyTaxiRepository;
  final LocationRepository _locationRepository;

  // A position lost on the way keeps the search where it was.
  Stream<Result<List<NearbyTaxi>>> call({required Coordinates around}) =>
      searchCenters(
        _locationRepository.watchPosition().whereType<Ok<Coordinates>>().map(
          (position) => position.value,
        ),
        from: around,
      ).switchMap(_watchAround);

  Stream<Result<List<NearbyTaxi>>> _watchAround(Coordinates center) =>
      _nearbyTaxiRepository
          .watchNearbyTaxis(around: center, radiusMeters: reachableRadiusMeters)
          .map(
            (result) => switch (result) {
              Ok(:final value) => Result.ok(
                reachableClosestFirst(value, around: center),
              ),
              Error(:final error) => Result.error(error),
            },
          );

  // Where to search, [from] first, then each position more than
  // [recenterDistanceMeters] away from the latest search.
  static Stream<Coordinates> searchCenters(
    Stream<Coordinates> positions, {
    required Coordinates from,
  }) async* {
    var center = from;
    yield center;
    await for (final position in positions) {
      if (center.distanceTo(position) <= recenterDistanceMeters) continue;
      center = position;
      yield center;
    }
  }

  // A taxi free now that was not among the [known] ones, e.g. those free when
  // the estimate was refused: the same taxis would be refused again (too few
  // seats for the passengers), so only a new one is worth a new estimate.
  static bool hasNewTaxi(
    List<NearbyTaxi> taxis, {
    required Set<String> known,
  }) => taxis.any((taxi) => !known.contains(taxi.id));

  static List<NearbyTaxi> reachableClosestFirst(
    List<NearbyTaxi> taxis, {
    required Coordinates around,
  }) {
    double distanceTo(NearbyTaxi taxi) => around.distanceTo(taxi.position);

    return taxis
        .where((taxi) => taxi.isAvailable)
        .where((taxi) => distanceTo(taxi) <= reachableRadiusMeters)
        .toList()
      ..sort((a, b) => distanceTo(a).compareTo(distanceTo(b)));
  }
}

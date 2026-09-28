import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';
import 'package:mobile/features/passenger_home/domain/repositories/nearby_taxi_repository.dart';

// The free taxis the passenger can order, closest first, again each time one
// of them moves.
class WatchNearbyTaxisUseCase {
  const WatchNearbyTaxisUseCase({
    required NearbyTaxiRepository nearbyTaxiRepository,
  }) : _nearbyTaxiRepository = nearbyTaxiRepository;

  static const reachableRadiusMeters = 5000.0;

  final NearbyTaxiRepository _nearbyTaxiRepository;

  Stream<Result<List<NearbyTaxi>>> call({required Coordinates around}) =>
      _nearbyTaxiRepository
          .watchNearbyTaxis(around: around, radiusMeters: reachableRadiusMeters)
          .map(
            (result) => switch (result) {
              Ok(:final value) => Result.ok(
                reachableClosestFirst(value, around: around),
              ),
              Error(:final error) => Result.error(error),
            },
          );

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

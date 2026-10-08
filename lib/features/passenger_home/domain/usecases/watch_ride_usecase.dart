import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/core/domain/repositories/route_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/tracked_ride.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

// Follows a ride. Each update of a moving taxi also brings its road: to the
// passenger while the driver comes, with the time left to the pickup, then
// to the destination once the passenger is in.
class WatchRideUseCase {
  const WatchRideUseCase({
    required RideRepository rideRepository,
    required RouteRepository routeRepository,
  }) : _rideRepository = rideRepository,
       _routeRepository = routeRepository;

  final RideRepository _rideRepository;
  final RouteRepository _routeRepository;

  // Not an async* with await for: its cancel would wait for the next update,
  // which does not come while the taxi is stopped.
  Stream<Result<TrackedRide>> call(String rideId) => _rideRepository
      .watchRide(rideId)
      .asyncMap(
        (result) async => switch (result) {
          Error(:final error) => Result.error(error),
          Ok(value: final RideDriverApproaching ride) => Result.ok(
            await _withApproach(ride),
          ),
          Ok(value: final RideInProgress ride) => Result.ok(
            TrackedRide(
              ride: ride,
              remainingRoute: await _route(
                from: ride.taxiPosition,
                to: ride.destination,
              ),
            ),
          ),
          Ok(:final value) => Result.ok(TrackedRide(ride: value)),
        },
      );

  Future<TrackedRide> _withApproach(RideDriverApproaching ride) async {
    final approach = await _route(from: ride.driverPosition, to: ride.pickup);
    return TrackedRide(
      ride: approach == null
          ? ride
          : ride.withEtaMinutes(approach.durationMinutes),
      remainingRoute: approach,
    );
  }

  // Without a route, the ride is still followed, just without a line.
  Future<RideRoute?> _route({
    required Coordinates from,
    required Coordinates to,
  }) async => switch (await _routeRepository.getRoute(from: from, to: to)) {
    Ok(:final value) => value,
    Error() => null,
  };
}

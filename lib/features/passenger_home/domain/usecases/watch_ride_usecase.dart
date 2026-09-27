import 'package:mobile/core/domain/repositories/route_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/tracked_ride.dart';
import 'package:mobile/features/passenger_home/domain/repositories/ride_repository.dart';

// Follows a ride. Once the passenger is in the taxi, each update also brings
// the road left from the taxi to the destination.
class WatchRideUseCase {
  const WatchRideUseCase({
    required RideRepository rideRepository,
    required RouteRepository routeRepository,
  }) : _rideRepository = rideRepository,
       _routeRepository = routeRepository;

  final RideRepository _rideRepository;
  final RouteRepository _routeRepository;

  Stream<Result<TrackedRide>> call(String rideId) async* {
    await for (final result in _rideRepository.watchRide(rideId)) {
      switch (result) {
        case Error(:final error):
          yield Result.error(error);
        case Ok(value: final RideInProgress ride):
          final route = await _routeRepository.getRoute(
            from: ride.taxiPosition,
            to: ride.destination,
          );
          // Without a route, the ride is still followed, just without a line.
          yield Result.ok(
            TrackedRide(
              ride: ride,
              remainingRoute: switch (route) {
                Ok(:final value) => value,
                Error() => null,
              },
            ),
          );
        case Ok(:final value):
          yield Result.ok(TrackedRide(ride: value));
      }
    }
  }
}

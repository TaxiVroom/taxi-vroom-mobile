import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/route_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/routed_ride_request.dart';
import 'package:mobile/features/driver_home/domain/repositories/ride_request_repository.dart';

// Follows the ride requests offered to an online driver, each with the road
// to the passenger and the road to the destination.
class WatchRideRequestsUseCase {
  const WatchRideRequestsUseCase({
    required RideRequestRepository rideRequestRepository,
    required RouteRepository routeRepository,
  }) : _rideRequestRepository = rideRequestRepository,
       _routeRepository = routeRepository;

  final RideRequestRepository _rideRequestRepository;
  final RouteRepository _routeRepository;

  Stream<Result<RoutedRideRequest>> call({
    required Coordinates driverPosition,
  }) async* {
    final requests = _rideRequestRepository.watchRideRequests(
      around: driverPosition,
    );
    await for (final result in requests) {
      switch (result) {
        case Error(:final error):
          yield Result.error(error);
        case Ok(value: final request):
          final (approach, trip) = await (
            _routeRepository.getRoute(
              from: driverPosition,
              to: request.pickup,
            ),
            _routeRepository.getRoute(
              from: request.pickup,
              to: request.destination,
            ),
          ).wait;
          // Without a road, the request is still offered, just without it.
          yield Result.ok(
            RoutedRideRequest(
              request: request,
              approach: switch (approach) {
                Ok(:final value) => value,
                Error() => null,
              },
              trip: switch (trip) {
                Ok(:final value) => value,
                Error() => null,
              },
            ),
          );
      }
    }
  }
}

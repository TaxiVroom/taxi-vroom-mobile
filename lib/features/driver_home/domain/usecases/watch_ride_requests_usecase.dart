import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/route_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_request.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_request_update.dart';
import 'package:mobile/features/driver_home/domain/entities/routed_ride_request.dart';
import 'package:mobile/features/driver_home/domain/repositories/ride_request_repository.dart';

// Follows the ride requests offered to an online driver, each with the road
// to the passenger and the road to the destination, and tells when the
// passenger cancels one before the driver answered.
class WatchRideRequestsUseCase {
  const WatchRideRequestsUseCase({
    required RideRequestRepository rideRequestRepository,
    required RouteRepository routeRepository,
  }) : _rideRequestRepository = rideRequestRepository,
       _routeRepository = routeRepository;

  final RideRequestRepository _rideRequestRepository;
  final RouteRepository _routeRepository;

  // Not an async* with await for: its cancel would wait for the next
  // request, which may never come.
  Stream<Result<RideRequestUpdate>> call({
    required Coordinates driverPosition,
  }) {
    // The request last offered, to tell why it is taken back.
    RideRequest? offered;

    Future<Result<RideRequestUpdate>?> update(
      Result<RideRequest?> result,
    ) async {
      switch (result) {
        case Error(:final error):
          return Result.error(error);
        case Ok(value: final request?):
          offered = request;
          final offer = await _withRoads(request, driverPosition);
          return Result.ok(IncomingRideRequest(offer: offer));
        case Ok(value: null):
          final takenBack = offered;
          offered = null;
          // None was offered, or its time ran out: nothing to tell.
          if (takenBack == null || takenBack.isExpired(DateTime.now())) {
            return null;
          }
          return Result.ok(CancelledRideRequest(requestId: takenBack.id));
      }
    }

    return _rideRequestRepository
        .watchRideRequests(around: driverPosition)
        .asyncMap(update)
        .where((update) => update != null)
        .cast<Result<RideRequestUpdate>>();
  }

  // Without a road, the request is still offered, just without it.
  Future<RoutedRideRequest> _withRoads(
    RideRequest request,
    Coordinates driverPosition,
  ) async {
    final (approach, trip) = await (
      _routeRepository.getRoute(from: driverPosition, to: request.pickup),
      _routeRepository.getRoute(from: request.pickup, to: request.destination),
    ).wait;
    return RoutedRideRequest(
      request: request,
      approach: switch (approach) {
        Ok(:final value) => value,
        Error() => null,
      },
      trip: switch (trip) {
        Ok(:final value) => value,
        Error() => null,
      },
    );
  }
}

import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/guidance.dart';
import 'package:mobile/core/domain/entities/navigation_route.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/domain/repositories/route_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driving_position_repository.dart';

// Guides the driver from where they are to [to]: the turn-by-turn route is
// computed once, guided from its start right away, then each new position
// gives the next maneuver.
class WatchGuidanceUseCase {
  const WatchGuidanceUseCase({
    required LocationRepository locationRepository,
    required RouteRepository routeRepository,
    required DrivingPositionRepository drivingPositionRepository,
  }) : _locationRepository = locationRepository,
       _routeRepository = routeRepository,
       _drivingPositionRepository = drivingPositionRepository;

  final LocationRepository _locationRepository;
  final RouteRepository _routeRepository;
  final DrivingPositionRepository _drivingPositionRepository;

  // Without [from], the route starts from the driver's current position.
  Stream<Result<Guidance>> call({
    required Coordinates to,
    Coordinates? from,
  }) async* {
    final Coordinates start;
    switch (from == null
        ? await _locationRepository.getCurrentPosition()
        : Result.ok(from)) {
      case Ok(:final value):
        start = value;
      case Error(:final error):
        yield Result.error(error);
        return;
    }

    final NavigationRoute route;
    switch (await _routeRepository.getNavigationRoute(from: start, to: to)) {
      case Ok(:final value):
        route = value;
      case Error(:final error):
        yield Result.error(error);
        return;
    }

    // Guided at once from where the route starts: the next GPS position may
    // take seconds, and the driver would see an empty screen meanwhile.
    yield Result.ok(route.guidanceFrom(start));

    // yield*, not await for: leaving the screen must stop the guidance at
    // once, even while the taxi is stopped and no new position comes.
    yield* _drivingPositionRepository
        .watchPosition(along: route.route.path)
        .map(
          (result) => switch (result) {
            Ok(:final value) => Result.ok(route.guidanceFrom(value)),
            Error(:final error) => Result.error(error),
          },
        );
  }
}

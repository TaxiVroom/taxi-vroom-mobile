import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/guidance.dart';
import 'package:mobile/core/domain/entities/navigation_route.dart';
import 'package:mobile/core/domain/entities/navigation_step.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/domain/repositories/route_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driving_position_repository.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_guidance_usecase.dart';

// Five points northward, about 111 m apart: 445 m in all.
const _path = [
  Coordinates(latitude: 48, longitude: 7),
  Coordinates(latitude: 48.001, longitude: 7),
  Coordinates(latitude: 48.002, longitude: 7),
  Coordinates(latitude: 48.003, longitude: 7),
  Coordinates(latitude: 48.004, longitude: 7),
];

final _route = NavigationRoute(
  route: const RideRoute(distanceKm: 0.445, durationMinutes: 4, path: _path),
  steps: [
    NavigationStep(
      maneuver: Maneuver.depart,
      location: _path[0],
      roadName: 'Rue Kirschleger',
    ),
    NavigationStep(
      maneuver: Maneuver.right,
      location: _path[2],
      roadName: 'Rue du Dôme',
    ),
    NavigationStep(
      maneuver: Maneuver.arrive,
      location: _path[4],
      roadName: '',
    ),
  ],
);

// The phone: where it is when asked.
class _FakeLocationRepository implements LocationRepository {
  @override
  Future<Result<Coordinates>> getCurrentPosition() async => Result.ok(_path[0]);

  @override
  Stream<Result<Coordinates>> watchPosition({bool inBackground = false}) =>
      throw UnimplementedError();

  @override
  Future<void> openSettings() => throw UnimplementedError();
}

// Mapbox: the turn-by-turn route.
class _FakeRouteRepository implements RouteRepository {
  @override
  Future<Result<RideRoute>> getRoute({
    required Coordinates from,
    required Coordinates to,
    DateTime? arriveBy,
  }) => throw UnimplementedError();

  @override
  Future<Result<NavigationRoute>> getNavigationRoute({
    required Coordinates from,
    required Coordinates to,
  }) async => Result.ok(_route);
}

// The GPS while driving: no position until the test sends one.
class _SilentDrivingPositionRepository implements DrivingPositionRepository {
  final positions = StreamController<Result<Coordinates>>();

  @override
  Stream<Result<Coordinates>> watchPosition({
    required List<Coordinates> along,
  }) => positions.stream;
}

void main() {
  group('WatchGuidanceUseCase', () {
    test('the route ready: guided from the start at once, '
        'without waiting for the next GPS position', () async {
      // Arrange
      final drivingPositions = _SilentDrivingPositionRepository();
      final useCase = WatchGuidanceUseCase(
        locationRepository: _FakeLocationRepository(),
        routeRepository: _FakeRouteRepository(),
        drivingPositionRepository: drivingPositions,
      );

      // Act
      final first = await useCase(to: _path[4]).first;

      // Assert
      final guidance = (first as Ok<Guidance>).value;
      expect(guidance, _route.guidanceFrom(_path[0]));
      expect(guidance.roadName, 'Rue du Dôme');
    });

    test('then each GPS position moves the guidance on', () async {
      // Arrange
      final drivingPositions = _SilentDrivingPositionRepository();
      final useCase = WatchGuidanceUseCase(
        locationRepository: _FakeLocationRepository(),
        routeRepository: _FakeRouteRepository(),
        drivingPositionRepository: drivingPositions,
      );

      // Act
      final guidances = useCase(to: _path[4]).take(2).toList();
      await Future<void>.delayed(Duration.zero);
      drivingPositions.positions.add(Result.ok(_path[3]));

      // Assert
      final second = (await guidances)[1];
      expect(
        (second as Ok<Guidance>).value,
        _route.guidanceFrom(_path[3]),
      );
    });
  });
}

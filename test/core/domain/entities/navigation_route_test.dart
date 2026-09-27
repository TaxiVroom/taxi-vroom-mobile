import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/navigation_route.dart';
import 'package:mobile/core/domain/entities/navigation_step.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';

// Five points northward, about 111 m apart: 445 m in all.
const _path = [
  Coordinates(latitude: 48, longitude: 7),
  Coordinates(latitude: 48.001, longitude: 7),
  Coordinates(latitude: 48.002, longitude: 7),
  Coordinates(latitude: 48.003, longitude: 7),
  Coordinates(latitude: 48.004, longitude: 7),
];

// Depart, turn right on "Rue du Dôme" at the middle point, then arrive.
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

void main() {
  group('NavigationRoute', () {
    group('guidanceFrom', () {
      test('at the start: the next turn, its distance and all the time', () {
        // Arrange
        final position = _path[0];

        // Act
        final guidance = _route.guidanceFrom(position);

        // Assert
        expect(guidance.nextManeuver, Maneuver.right);
        expect(guidance.roadName, 'Rue du Dôme');
        expect(guidance.metersToManeuver, closeTo(222, 1));
        expect(guidance.metersLeft, closeTo(445, 1));
        expect(guidance.minutesLeft, 4);
      });

      test('past the turn: the arrival comes next', () {
        // Arrange
        final position = _path[3];

        // Act
        final guidance = _route.guidanceFrom(position);

        // Assert
        expect(guidance.nextManeuver, Maneuver.arrive);
        expect(guidance.metersToManeuver, closeTo(111, 1));
      });

      test('time left follows the distance left, rounded up', () {
        // Arrange
        final position = _path[3];

        // Act
        final guidance = _route.guidanceFrom(position);

        // Assert
        expect(guidance.minutesLeft, 1);
      });

      test('at the end: arrived, nothing left', () {
        // Arrange
        final position = _path[4];

        // Act
        final guidance = _route.guidanceFrom(position);

        // Assert
        expect(guidance.nextManeuver, Maneuver.arrive);
        expect(guidance.metersToManeuver, 0);
        expect(guidance.metersLeft, 0);
        expect(guidance.minutesLeft, 0);
      });

      test('points the map along the road and at the next maneuver', () {
        // Arrange
        final position = _path[0];

        // Act
        final guidance = _route.guidanceFrom(position);

        // Assert
        expect(guidance.heading, closeTo(0, 0.01));
        expect(guidance.maneuverLocation, _path[2]);
      });

      test('the road left starts from the driver', () {
        // Arrange
        const position = Coordinates(latitude: 48.0011, longitude: 7);

        // Act
        final guidance = _route.guidanceFrom(position);

        // Assert
        expect(guidance.remainingPath, [
          position,
          _path[2],
          _path[3],
          _path[4],
        ]);
      });
    });
  });
}

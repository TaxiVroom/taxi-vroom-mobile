import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';

void main() {
  group('Coordinates', () {
    group('distanceTo', () {
      test('0.001 degree of latitude is about 111 meters', () {
        // Arrange
        const from = Coordinates(latitude: 48, longitude: 7);
        const to = Coordinates(latitude: 48.001, longitude: 7);

        // Act
        final meters = from.distanceTo(to);

        // Assert
        expect(meters, closeTo(111.2, 0.1));
      });

      test('is 0 for the same point', () {
        // Arrange
        const point = Coordinates(latitude: 48.58, longitude: 7.75);

        // Act
        final meters = point.distanceTo(point);

        // Assert
        expect(meters, 0);
      });
    });

    group('bearingTo', () {
      const from = Coordinates(latitude: 48, longitude: 7);

      test('is 0 towards the north', () {
        // Arrange
        const to = Coordinates(latitude: 48.01, longitude: 7);

        // Act
        final bearing = from.bearingTo(to);

        // Assert
        expect(bearing, closeTo(0, 0.01));
      });

      test('is 90 towards the east', () {
        // Arrange
        const to = Coordinates(latitude: 48, longitude: 7.01);

        // Act
        final bearing = from.bearingTo(to);

        // Assert
        expect(bearing, closeTo(90, 0.01));
      });

      test('stays between 0 and 360 towards the west', () {
        // Arrange
        const to = Coordinates(latitude: 48, longitude: 6.99);

        // Act
        final bearing = from.bearingTo(to);

        // Assert
        expect(bearing, closeTo(270, 0.01));
      });
    });
  });
}

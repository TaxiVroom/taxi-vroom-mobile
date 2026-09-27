import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';

void main() {
  group('RideRoute', () {
    group('pickupForArrival', () {
      test('subtracts the trip duration and the safety margin', () {
        // Arrange
        const route = RideRoute(distanceKm: 14, durationMinutes: 22, path: []);

        // Act
        final pickup = route.pickupForArrival(DateTime(2026, 9, 28, 9));

        // Assert
        expect(pickup, DateTime(2026, 9, 28, 8, 28));
      });
    });
  });
}

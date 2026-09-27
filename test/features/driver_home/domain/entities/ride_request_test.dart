import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_request.dart';

void main() {
  group('RideRequest', () {
    final sentAt = DateTime(2026, 9, 28, 8, 7);
    final request = RideRequest(
      id: 'request',
      sentAt: sentAt,
      minPriceCents: 2700,
      maxPriceCents: 3300,
      distanceKm: 14.8,
      pickupName: 'Place Broglie',
      pickup: const Coordinates(latitude: 48.58, longitude: 7.75),
      destinationName: 'Aéroport Strasbourg-Entzheim',
      destination: const Coordinates(latitude: 48.54, longitude: 7.63),
      customerFirstName: 'Camille',
      customerRating: 4.8,
      passengerCount: 1,
      luggageCount: 1,
    );

    group('secondsLeft', () {
      test('gives 15 seconds to answer', () {
        // Arrange
        final now = sentAt;

        // Act
        final secondsLeft = request.secondsLeft(now);

        // Assert
        expect(secondsLeft, 15);
      });

      test('rounds a started second up', () {
        // Arrange
        final now = sentAt.add(const Duration(milliseconds: 3200));

        // Act
        final secondsLeft = request.secondsLeft(now);

        // Assert
        expect(secondsLeft, 12);
      });

      test('never goes below 0 once the time is up', () {
        // Arrange
        final now = sentAt.add(const Duration(seconds: 20));

        // Act
        final secondsLeft = request.secondsLeft(now);

        // Assert
        expect(secondsLeft, 0);
      });
    });

    group('isExpired', () {
      test('still open just before 15 seconds', () {
        // Arrange
        final now = sentAt.add(const Duration(milliseconds: 14900));

        // Act
        final isExpired = request.isExpired(now);

        // Assert
        expect(isExpired, isFalse);
      });

      test('expired at 15 seconds', () {
        // Arrange
        final now = sentAt.add(RideRequest.responseTime);

        // Act
        final isExpired = request.isExpired(now);

        // Assert
        expect(isExpired, isTrue);
      });
    });
  });
}

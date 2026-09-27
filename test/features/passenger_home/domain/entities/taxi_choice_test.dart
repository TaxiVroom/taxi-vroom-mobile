import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_route.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_choice.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';

void main() {
  group('TaxiChoice', () {
    const offer = TaxiOffer(
      id: 'taxi',
      name: 'Taxi',
      description: '4 places',
      pickupEtaMinutes: 4,
      minPriceCents: 2000,
      maxPriceCents: 2500,
    );
    const choice = TaxiChoice(
      route: RideRoute(distanceKm: 14, durationMinutes: 17, path: []),
      offers: [offer],
    );

    group('estimatedArrival', () {
      test('ordered now: adds the taxi approach, then the trip', () {
        // Arrange
        final now = DateTime(2026, 9, 28, 14, 10);

        // Act
        final arrival = choice.estimatedArrival(offer: offer, now: now);

        // Assert
        expect(arrival, DateTime(2026, 9, 28, 14, 31));
      });

      test('booked: adds only the trip to the pickup time', () {
        // Arrange
        final now = DateTime(2026, 9, 28, 14, 10);

        // Act
        final arrival = choice.estimatedArrival(
          offer: offer,
          now: now,
          scheduledPickup: DateTime(2026, 9, 29, 8),
        );

        // Assert
        expect(arrival, DateTime(2026, 9, 29, 8, 17));
      });
    });
  });
}

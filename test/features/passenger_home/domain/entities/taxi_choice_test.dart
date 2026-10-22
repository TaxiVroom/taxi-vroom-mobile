import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_choice.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_tariff.dart';

void main() {
  group('TaxiChoice', () {
    final offer = TaxiOffer(
      id: 'taxi',
      rideId: 'ride-id',
      name: 'Taxi',
      description: '4 places',
      pickupEtaMinutes: 4,
      minPriceCents: 2000,
      maxPriceCents: 2500,
      tariff: TaxiTariff(
        departmentCode: '67',
        validFrom: DateTime(2026, 2),
        decree: 'Arrêté préfectoral du 26 janvier 2026',
        pickupCents: 310,
        kmCentsA: 101,
        kmCentsB: 143,
        kmCentsC: 202,
        kmCentsD: 286,
        hourlyCents: 3780,
        minimumFareCents: 800,
        nightStartMinute: 19 * 60,
        nightEndMinute: 7 * 60,
      ),
    );
    final choice = TaxiChoice(
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

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/driver_home/domain/entities/fare_supplement.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';

void main() {
  group('RideCheckout', () {
    const bulkyLuggage = FareSupplement(
      id: 'bulky-luggage',
      label: 'Bagage encombrant',
      amountCents: 200,
    );
    const fifthPassenger = FareSupplement(
      id: 'fifth-passenger',
      label: '5e passager et plus',
      amountCents: 400,
    );
    const checkout = RideCheckout(
      meterCents: 2967,
      supplements: [bulkyLuggage, fifthPassenger],
    );

    group('totalCents', () {
      test('is unknown until the meter amount is typed', () {
        // Arrange
        final notTyped = checkout
            .withMeterCents(null)
            .withCount(bulkyLuggage, 1);

        // Act
        final total = notTyped.totalCents;

        // Assert
        expect(total, isNull);
      });

      test('is the meter amount without supplements', () {
        // Arrange
        const noSupplement = checkout;

        // Act
        final total = noSupplement.totalCents;

        // Assert
        expect(total, 2967);
      });

      test('adds each supplement times its count', () {
        // Arrange
        final withSupplements = checkout
            .withCount(bulkyLuggage, 2)
            .withCount(fifthPassenger, 1);

        // Act
        final total = withSupplements.totalCents;

        // Assert
        expect(total, 2967 + 2 * 200 + 400);
      });

      test('follows the meter amount corrected by the driver', () {
        // Arrange
        final corrected = checkout
            .withCount(bulkyLuggage, 1)
            .withMeterCents(
              3000,
            );

        // Act
        final total = corrected.totalCents;

        // Assert
        expect(total, 3000 + 200);
      });
    });

    group('addedSupplements', () {
      test('keeps only the supplements added, with their count', () {
        // Arrange
        final withLuggage = checkout.withCount(bulkyLuggage, 2);

        // Act
        final added = withLuggage.addedSupplements;

        // Assert
        expect(added, [(bulkyLuggage, 2)]);
      });

      test('drops a supplement brought back to 0', () {
        // Arrange
        final removed = checkout
            .withCount(bulkyLuggage, 1)
            .withCount(bulkyLuggage, 0);

        // Act
        final added = removed.addedSupplements;

        // Assert
        expect(added, isEmpty);
      });
    });

    group('withCount', () {
      test('never goes below 0', () {
        // Arrange
        const none = checkout;

        // Act
        final lowered = none.withCount(bulkyLuggage, -1);

        // Assert
        expect(lowered.countOf(bulkyLuggage), 0);
      });
    });
  });
}

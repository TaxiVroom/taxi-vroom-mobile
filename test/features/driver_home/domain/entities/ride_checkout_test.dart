import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/driver_home/domain/entities/fare_supplement.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';

void main() {
  group('RideCheckout', () {
    const extraSupplement = FareSupplement(
      id: 'extra',
      label: 'Supplément',
      amountCents: 200,
    );
    const fifthPassenger = FareSupplement(
      id: 'fifth-passenger',
      label: '5e passager et plus',
      amountCents: 400,
    );
    // For a ride of 6 passengers: at most 2 beyond the fourth, 2 to start.
    const passengersBeyondFour = FareSupplement(
      id: 'fifth-passenger',
      label: '5e passager et plus',
      amountCents: 400,
      maxCount: 2,
      initialCount: 2,
    );
    const checkout = RideCheckout(
      meterCents: 2967,
      supplements: [extraSupplement, fifthPassenger],
    );

    group('totalCents', () {
      test('is unknown until the meter amount is typed', () {
        // Arrange
        final notTyped = checkout
            .withMeterCents(null)
            .withCount(extraSupplement, 1);

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
            .withCount(extraSupplement, 2)
            .withCount(fifthPassenger, 1);

        // Act
        final total = withSupplements.totalCents;

        // Assert
        expect(total, 2967 + 2 * 200 + 400);
      });

      test('follows the meter amount corrected by the driver', () {
        // Arrange
        final corrected = checkout
            .withCount(extraSupplement, 1)
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
        final withExtra = checkout.withCount(extraSupplement, 2);

        // Act
        final added = withExtra.addedSupplements;

        // Assert
        expect(added, [(extraSupplement, 2)]);
      });

      test('drops a supplement brought back to 0', () {
        // Arrange
        final removed = checkout
            .withCount(extraSupplement, 1)
            .withCount(extraSupplement, 0);

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
        final lowered = none.withCount(extraSupplement, -1);

        // Assert
        expect(lowered.countOf(extraSupplement), 0);
      });

      test('has no upper limit for a supplement without a maximum', () {
        // Arrange
        const none = checkout;

        // Act
        final raised = none.withCount(extraSupplement, 25);

        // Assert
        expect(raised.countOf(extraSupplement), 25);
      });

      test('never goes above the maximum of the supplement', () {
        // Arrange
        const sixPassengers = RideCheckout(
          meterCents: 2967,
          supplements: [extraSupplement, passengersBeyondFour],
        );

        // Act
        final raised = sixPassengers.withCount(passengersBeyondFour, 3);

        // Assert
        expect(raised.countOf(passengersBeyondFour), 2);
      });
    });

    group('canAdd', () {
      test('is always true for a supplement without a maximum', () {
        // Arrange
        final many = checkout.withCount(extraSupplement, 20);

        // Act
        final canAdd = many.canAdd(extraSupplement);

        // Assert
        expect(canAdd, isTrue);
      });

      test('is true below the maximum of the supplement', () {
        // Arrange
        const sixPassengers = RideCheckout(
          meterCents: 2967,
          supplements: [passengersBeyondFour],
        );
        final lowered = sixPassengers.withCount(passengersBeyondFour, 1);

        // Act
        final canAdd = lowered.canAdd(passengersBeyondFour);

        // Assert
        expect(canAdd, isTrue);
      });

      test('is false once the maximum is reached', () {
        // Arrange
        const sixPassengers = RideCheckout(
          meterCents: 2967,
          supplements: [passengersBeyondFour],
        );

        // Act
        final canAdd = sixPassengers.canAdd(passengersBeyondFour);

        // Assert
        expect(canAdd, isFalse);
      });
    });

    // The "5e passager et plus" line of a ride of 6 passengers: filled with
    // the 2 passengers beyond the fourth, which the driver may lower. Spec
    // taxi-vroom-api/docs/specs/nombre-de-passagers.md, situation 6.
    group('a supplement pre-filled by the ride', () {
      const sixPassengers = RideCheckout(
        meterCents: 2967,
        supplements: [extraSupplement, passengersBeyondFour],
      );

      test('starts at its initial count, counted in the total', () {
        // Arrange
        const untouched = sixPassengers;

        // Act
        final count = untouched.countOf(passengersBeyondFour);
        final total = untouched.totalCents;

        // Assert
        expect(count, 2);
        expect(total, 2967 + 2 * 400);
      });

      test('can be lowered to 0 and then leaves the added supplements', () {
        // Arrange
        final lowered = sixPassengers.withCount(passengersBeyondFour, 0);

        // Act
        final total = lowered.totalCents;
        final added = lowered.addedSupplements;

        // Assert
        expect(total, 2967);
        expect(added, isEmpty);
      });

      test('is among the added supplements without the driver touching it', () {
        // Arrange
        const untouched = sixPassengers;

        // Act
        final added = untouched.addedSupplements;

        // Assert
        expect(added, [(passengersBeyondFour, 2)]);
      });
    });
  });
}

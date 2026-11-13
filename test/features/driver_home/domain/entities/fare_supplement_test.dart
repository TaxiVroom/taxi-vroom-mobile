import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/driver_home/domain/entities/fare_supplement.dart';

void main() {
  group('FareSupplement.beyondFourthPassenger', () {
    test('has no line up to 4 passengers', () {
      // Arrange
      const passengerCount = 4;

      // Act
      final supplement = FareSupplement.beyondFourthPassenger(
        passengerCount: passengerCount,
        unitCents: 400,
      );

      // Assert
      expect(supplement, isNull);
    });

    test('counts the passengers beyond the fourth, filled to start', () {
      // Arrange
      const passengerCount = 6;

      // Act
      final supplement = FareSupplement.beyondFourthPassenger(
        passengerCount: passengerCount,
        unitCents: 400,
      );

      // Assert
      expect(supplement?.id, 'fifth-passenger');
      expect(supplement?.label, '5e passager et plus');
      expect(supplement?.amountCents, 400);
      expect(supplement?.maxCount, 2);
      expect(supplement?.initialCount, 2);
    });

    test('counts 4 beyond the fourth for the 8 seats of a taxi', () {
      // Arrange
      const passengerCount = 8;

      // Act
      final supplement = FareSupplement.beyondFourthPassenger(
        passengerCount: passengerCount,
        unitCents: 550,
      );

      // Assert
      expect(supplement?.maxCount, 4);
      expect(supplement?.initialCount, 4);
      expect(supplement?.amountCents, 550);
    });
  });
}

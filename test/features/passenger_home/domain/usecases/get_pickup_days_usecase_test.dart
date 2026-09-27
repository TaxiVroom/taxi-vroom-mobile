import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/passenger_home/domain/usecases/get_pickup_days_usecase.dart';

void main() {
  group('GetPickupDaysUseCase', () {
    group('isBookable', () {
      test('accepts a pickup 30 minutes from now', () {
        // Arrange
        final now = DateTime(2026, 9, 28, 14, 10);

        // Act
        final isBookable = GetPickupDaysUseCase.isBookable(
          DateTime(2026, 9, 28, 14, 40),
          now: now,
        );

        // Assert
        expect(isBookable, isTrue);
      });

      test('rejects a pickup less than 30 minutes from now', () {
        // Arrange
        final now = DateTime(2026, 9, 28, 14, 10);

        // Act
        final isBookable = GetPickupDaysUseCase.isBookable(
          DateTime(2026, 9, 28, 14, 39),
          now: now,
        );

        // Assert
        expect(isBookable, isFalse);
      });
    });

    group('call', () {
      test('starts today at the first slot 30 minutes from now', () {
        // Arrange
        const useCase = GetPickupDaysUseCase();

        // Act
        final days = useCase(now: DateTime(2026, 9, 28, 14, 10));

        // Assert
        expect(days.first.date, DateTime(2026, 9, 28));
        expect(days.first.slots.first, DateTime(2026, 9, 28, 14, 45));
      });

      test('offers a slot every 15 minutes', () {
        // Arrange
        const useCase = GetPickupDaysUseCase();

        // Act
        final days = useCase(now: DateTime(2026, 9, 28, 14, 10));

        // Assert
        expect(days[1].slots.take(3), [
          DateTime(2026, 9, 29),
          DateTime(2026, 9, 29, 0, 15),
          DateTime(2026, 9, 29, 0, 30),
        ]);
      });

      test('offers days up to 30 days from today', () {
        // Arrange
        const useCase = GetPickupDaysUseCase();

        // Act
        final days = useCase(now: DateTime(2026, 9, 28, 14, 10));

        // Assert
        expect(days.last.date, DateTime(2026, 10, 28));
      });

      test('skips today when no slot is left', () {
        // Arrange
        const useCase = GetPickupDaysUseCase();

        // Act
        final days = useCase(now: DateTime(2026, 9, 28, 23, 50));

        // Assert
        expect(days.first.date, DateTime(2026, 9, 29));
      });
    });
  });
}

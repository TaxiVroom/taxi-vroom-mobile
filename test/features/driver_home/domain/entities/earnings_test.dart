import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/driver_home/domain/entities/earnings.dart';

void main() {
  group('Earnings', () {
    Earnings earningsWithBestDay(int bestCents) => Earnings(
      period: EarningsPeriod.week,
      days: [
        DayEarnings(day: DateTime(2026, 11, 9), amountCents: bestCents),
        DayEarnings(day: DateTime(2026, 11, 10), amountCents: 0),
      ],
      rideCount: 3,
    );

    test('the total adds the earnings of every day', () {
      // Arrange
      final earnings = Earnings(
        period: EarningsPeriod.week,
        days: [
          DayEarnings(day: DateTime(2026, 9, 21), amountCents: 5000),
          DayEarnings(day: DateTime(2026, 9, 22), amountCents: 10000),
          DayEarnings(day: DateTime(2026, 9, 23), amountCents: 0),
        ],
        rideCount: 12,
      );

      // Act
      final total = earnings.totalCents;

      // Assert
      expect(total, 5000 + 10000 + 0);
    });

    test('the axis tops at the round amount just above the best day', () {
      // Arrange: best day 95,10 €, the 50 € step doubled covers it.
      final earnings = earningsWithBestDay(9510);

      // Act
      final top = earnings.axisTopCents;

      // Assert
      expect(top, 10000);
    });

    test('a best day on a round amount tops the axis exactly', () {
      // Arrange: best day 20 €, the 10 € step doubled.
      final earnings = earningsWithBestDay(2000);

      // Act
      final top = earnings.axisTopCents;

      // Assert
      expect(top, 2000);
    });

    test('a period without earnings has a 20 € axis', () {
      // Arrange
      final earnings = earningsWithBestDay(0);

      // Act
      final top = earnings.axisTopCents;

      // Assert
      expect(top, 2000);
    });

    test('above 1 000 € the step is a multiple of 500 €', () {
      // Arrange: best day 1 200 €, half of it rounded up to 1 000 €.
      final earnings = earningsWithBestDay(120000);

      // Act
      final top = earnings.axisTopCents;

      // Assert
      expect(top, 200000);
    });

    test('a bar is sized against the top of the axis', () {
      // Arrange: best day 95,10 €, axis at 100 €.
      final earnings = earningsWithBestDay(9510);
      final day = DayEarnings(day: DateTime(2026, 11, 11), amountCents: 5000);

      // Act
      final share = earnings.shareOfAxis(day);

      // Assert
      expect(share, 0.5);
    });
  });
}

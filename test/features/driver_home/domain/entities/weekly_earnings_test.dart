import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/driver_home/domain/entities/weekly_earnings.dart';

void main() {
  group('WeeklyEarnings', () {
    final monday = DayEarnings(day: DateTime(2026, 9, 21), amountCents: 5000);
    final tuesday = DayEarnings(day: DateTime(2026, 9, 22), amountCents: 10000);
    final wednesday = DayEarnings(day: DateTime(2026, 9, 23), amountCents: 0);
    final earnings = WeeklyEarnings(
      days: [monday, tuesday, wednesday],
      rideCount: 12,
      onlineMinutes: 600,
      paidInAppCents: 11250,
      collectedOnBoardCents: 3750,
      nextPayoutDate: DateTime(2026, 9, 28),
    );

    test('the total adds what was paid in the app and on board', () {
      // Arrange
      const expected = 11250 + 3750;

      // Act
      final total = earnings.totalCents;

      // Assert
      expect(total, expected);
    });

    test('only what was paid in the app is transferred', () {
      // Arrange
      const expected = 11250;

      // Act
      final payout = earnings.nextPayoutCents;

      // Assert
      expect(payout, expected);
    });

    test('bars are sized against the best day', () {
      // Arrange
      final days = [monday, tuesday, wednesday];

      // Act
      final shares = days.map(earnings.shareOfBestDay).toList();

      // Assert
      expect(shares, [0.5, 1, 0]);
    });

    test('a week without earnings has empty bars', () {
      // Arrange
      final empty = WeeklyEarnings(
        days: [wednesday],
        rideCount: 0,
        onlineMinutes: 0,
        paidInAppCents: 0,
        collectedOnBoardCents: 0,
        nextPayoutDate: DateTime(2026, 9, 28),
      );

      // Act
      final share = empty.shareOfBestDay(wednesday);

      // Assert
      expect(share, 0);
    });
  });
}

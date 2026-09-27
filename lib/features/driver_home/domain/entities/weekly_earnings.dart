import 'package:equatable/equatable.dart';

// What the driver earned on one day.
class DayEarnings extends Equatable {
  const DayEarnings({required this.day, required this.amountCents});

  // Midnight of that day.
  final DateTime day;
  final int amountCents;

  @override
  List<Object?> get props => [day, amountCents];
}

// The "Gains" tab: the week, day by day, and how the money comes in.
class WeeklyEarnings extends Equatable {
  const WeeklyEarnings({
    required this.days,
    required this.rideCount,
    required this.onlineMinutes,
    required this.paidInAppCents,
    required this.collectedOnBoardCents,
    required this.nextPayoutDate,
  });

  // Monday to Sunday.
  final List<DayEarnings> days;

  final int rideCount;
  final int onlineMinutes;

  // Paid through the app: transferred to the driver.
  final int paidInAppCents;

  // Card or cash in the taxi: already with the driver.
  final int collectedOnBoardCents;

  final DateTime nextPayoutDate;

  int get totalCents => paidInAppCents + collectedOnBoardCents;

  // Only what was paid in the app is transferred.
  int get nextPayoutCents => paidInAppCents;

  // The height of a day's bar, from 0 to 1: the best day is the full bar.
  double shareOfBestDay(DayEarnings day) {
    final best = days.fold(
      0,
      (best, d) => d.amountCents > best ? d.amountCents : best,
    );
    return best == 0 ? 0 : day.amountCents / best;
  }

  @override
  List<Object?> get props => [
    days,
    rideCount,
    onlineMinutes,
    paidInAppCents,
    collectedOnBoardCents,
    nextPayoutDate,
  ];
}

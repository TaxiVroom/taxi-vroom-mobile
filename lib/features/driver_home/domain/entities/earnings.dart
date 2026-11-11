import 'package:equatable/equatable.dart';

// What the "Gains" tab shows: spec
// taxi-vroom-api/docs/specs/gains-du-chauffeur.md.
enum EarningsPeriod { today, week, month }

// What the driver earned on one day.
class DayEarnings extends Equatable {
  const DayEarnings({required this.day, required this.amountCents});

  // Midnight of that day.
  final DateTime day;
  final int amountCents;

  @override
  List<Object?> get props => [day, amountCents];
}

// The "Gains" tab: a period, day by day. Every ride is paid on board, by
// card or cash: the money is already with the driver.
class Earnings extends Equatable {
  const Earnings({
    required this.period,
    required this.days,
    required this.rideCount,
  });

  // Steps of the chart's axis, from 10 € to 500 €.
  static const _axisStepsCents = [
    1000,
    2000,
    2500,
    5000,
    10000,
    20000,
    25000,
    50000,
  ];

  final EarningsPeriod period;

  // Every day of the period, in order: today alone, Monday to Sunday, or the
  // whole month.
  final List<DayEarnings> days;

  final int rideCount;

  int get totalCents => days.fold(0, (total, day) => total + day.amountCents);

  // The top of the chart's axis: twice the smallest round step that covers
  // the best day. Its marks are 0, the step and the top.
  int get axisTopCents => _axisStepCents * 2;

  int get _axisStepCents {
    final bestCents = days.fold(
      0,
      (best, d) => d.amountCents > best ? d.amountCents : best,
    );
    for (final step in _axisStepsCents) {
      if (step * 2 >= bestCents) return step;
    }
    // Above 1 000 €: half of the best day, rounded up to 500 €.
    final largest = _axisStepsCents.last;
    return (bestCents / 2 / largest).ceil() * largest;
  }

  // The height of a day's bar, from 0 to 1: the top of the axis is 1.
  double shareOfAxis(DayEarnings day) => day.amountCents / axisTopCents;

  @override
  List<Object?> get props => [period, days, rideCount];
}

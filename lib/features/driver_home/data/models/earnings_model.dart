import 'package:mobile/features/driver_home/domain/entities/earnings.dart';

class EarningsModel {
  const EarningsModel({required this.days, required this.rideCount});

  factory EarningsModel.fromJson(Map<String, dynamic> json) => EarningsModel(
    days: [
      for (final day in json['days'] as List<dynamic>)
        (
          // "2026-11-11", a day in Paris: midnight of that day.
          day: DateTime.parse((day as Map<String, dynamic>)['day'] as String),
          amountCents: day['amountCents'] as int,
        ),
    ],
    rideCount: json['rideCount'] as int,
  );

  final List<({DateTime day, int amountCents})> days;
  final int rideCount;

  // The period is the one asked for.
  Earnings toDomain(EarningsPeriod period) => Earnings(
    period: period,
    days: [
      for (final day in days)
        DayEarnings(day: day.day, amountCents: day.amountCents),
    ],
    rideCount: rideCount,
  );
}

import 'package:mobile/features/driver_home/domain/entities/weekly_earnings.dart';

class WeeklyEarningsModel {
  const WeeklyEarningsModel({
    required this.days,
    required this.rideCount,
    required this.onlineMinutes,
  });

  factory WeeklyEarningsModel.fromJson(Map<String, dynamic> json) =>
      WeeklyEarningsModel(
        days: [
          for (final day in json['days'] as List<dynamic>)
            (
              day: DateTime.parse(
                (day as Map<String, dynamic>)['day'] as String,
              ),
              amountCents: day['amountCents'] as int,
            ),
        ],
        rideCount: json['rideCount'] as int,
        onlineMinutes: json['onlineMinutes'] as int,
      );

  final List<({DateTime day, int amountCents})> days;
  final int rideCount;
  final int onlineMinutes;

  WeeklyEarnings toDomain() => WeeklyEarnings(
    days: [
      for (final day in days)
        DayEarnings(day: day.day, amountCents: day.amountCents),
    ],
    rideCount: rideCount,
    onlineMinutes: onlineMinutes,
  );
}

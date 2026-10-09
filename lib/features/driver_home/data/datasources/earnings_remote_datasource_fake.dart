import 'package:mobile/features/driver_home/data/datasources/earnings_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/models/weekly_earnings_model.dart';

/// Implémentation de développement avec données de test : la semaine en
/// cours, avec des gains jusqu'à aujourd'hui et rien les jours suivants.
class EarningsRemoteDataSourceFake implements EarningsRemoteDataSource {
  // Monday to Sunday.
  static const _dayAmountsCents = [7470, 9510, 5430, 11540, 13590, 8430, 4510];

  @override
  Future<WeeklyEarningsModel> getWeeklyEarnings() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final days = [
      for (var i = 0; i < 7; i++)
        (
          day: DateTime(monday.year, monday.month, monday.day + i),
          amountCents: i < now.weekday ? _dayAmountsCents[i] : 0,
        ),
    ];
    return WeeklyEarningsModel.fromJson({
      'days': [
        for (final day in days)
          {
            'day': day.day.toIso8601String(),
            'amountCents': day.amountCents,
          },
      ],
      'rideCount': 31,
      'onlineMinutes': 28 * 60 + 15,
    });
  }
}

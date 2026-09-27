import 'package:mobile/features/driver_home/data/models/weekly_earnings_model.dart';

// No backend endpoint yet: only the fake implementation exists.
abstract class EarningsRemoteDataSource {
  Future<WeeklyEarningsModel> getWeeklyEarnings();
}

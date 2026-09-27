import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/weekly_earnings.dart';

abstract class EarningsRepository {
  // The current week, Monday to Sunday.
  Future<Result<WeeklyEarnings>> getWeeklyEarnings();
}

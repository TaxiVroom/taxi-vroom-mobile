import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/earnings.dart';

abstract class EarningsRepository {
  // Today, the current week (Monday to Sunday) or the current month.
  Future<Result<Earnings>> getEarnings(EarningsPeriod period);
}

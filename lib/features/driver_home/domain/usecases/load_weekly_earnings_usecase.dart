import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/weekly_earnings.dart';
import 'package:mobile/features/driver_home/domain/repositories/earnings_repository.dart';

// The "Gains" tab.
class LoadWeeklyEarningsUseCase {
  const LoadWeeklyEarningsUseCase(this._earningsRepository);

  final EarningsRepository _earningsRepository;

  Future<Result<WeeklyEarnings>> call() =>
      _earningsRepository.getWeeklyEarnings();
}

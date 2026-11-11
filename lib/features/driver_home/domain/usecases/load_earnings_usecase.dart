import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/earnings.dart';
import 'package:mobile/features/driver_home/domain/repositories/earnings_repository.dart';

// The "Gains" tab, for the period the driver chose.
class LoadEarningsUseCase {
  const LoadEarningsUseCase(this._earningsRepository);

  final EarningsRepository _earningsRepository;

  Future<Result<Earnings>> call(EarningsPeriod period) =>
      _earningsRepository.getEarnings(period);
}

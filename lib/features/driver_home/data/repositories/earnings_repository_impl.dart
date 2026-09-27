import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/earnings_remote_datasource.dart';
import 'package:mobile/features/driver_home/domain/entities/weekly_earnings.dart';
import 'package:mobile/features/driver_home/domain/repositories/earnings_repository.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  const EarningsRepositoryImpl(this._dataSource);

  final EarningsRemoteDataSource _dataSource;

  @override
  Future<Result<WeeklyEarnings>> getWeeklyEarnings() async {
    try {
      final model = await _dataSource.getWeeklyEarnings();
      return Result.ok(model.toDomain());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

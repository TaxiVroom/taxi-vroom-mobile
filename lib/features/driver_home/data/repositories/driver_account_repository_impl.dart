import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_account_remote_datasource.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_account.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_account_repository.dart';

class DriverAccountRepositoryImpl implements DriverAccountRepository {
  const DriverAccountRepositoryImpl(this._dataSource);

  final DriverAccountRemoteDataSource _dataSource;

  @override
  Future<Result<DriverAccount>> getAccount() async {
    try {
      final model = await _dataSource.getAccount();
      return Result.ok(model.toDomain());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<void>> setNotificationsEnabled({required bool enabled}) async {
    try {
      await _dataSource.setNotificationsEnabled(enabled: enabled);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

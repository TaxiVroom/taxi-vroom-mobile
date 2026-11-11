import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/data/datasources/account_remote_datasource.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_account.dart';
import 'package:mobile/features/passenger_home/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._dataSource);

  final AccountRemoteDataSource _dataSource;

  @override
  Future<Result<PassengerAccount>> getAccount() async {
    try {
      return Result.ok((await _dataSource.getAccount()).toDomain());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

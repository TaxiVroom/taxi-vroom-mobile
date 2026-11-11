import 'package:dio/dio.dart';
import 'package:mobile/core/data/datasources/enterprise_contact_remote_datasource.dart';
import 'package:mobile/core/domain/repositories/enterprise_contact_repository.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';

class EnterpriseContactRepositoryImpl implements EnterpriseContactRepository {
  const EnterpriseContactRepositoryImpl(this._dataSource);

  final EnterpriseContactRemoteDataSource _dataSource;

  @override
  Future<Result<String>> getPhone() async {
    try {
      return Result.ok(await _dataSource.getPhone());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

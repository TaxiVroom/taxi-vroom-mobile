import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/registration/driver/data/datasources/commune_remote_datasource.dart';
import 'package:mobile/features/registration/driver/domain/entities/commune.dart';
import 'package:mobile/features/registration/driver/domain/repositories/commune_repository.dart';

class CommuneRepositoryImpl implements CommuneRepository {
  const CommuneRepositoryImpl(this._dataSource);

  final CommuneRemoteDataSource _dataSource;

  @override
  Future<Result<List<Commune>>> searchCommunes(String name) async {
    try {
      final models = await _dataSource.searchCommunes(name);
      return Result.ok(models.map((model) => model.toDomain()).toList());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

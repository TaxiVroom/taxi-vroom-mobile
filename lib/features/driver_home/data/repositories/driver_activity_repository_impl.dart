import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_activity_remote_datasource.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_activity.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_activity_repository.dart';

class DriverActivityRepositoryImpl implements DriverActivityRepository {
  const DriverActivityRepositoryImpl(this._dataSource);

  final DriverActivityRemoteDataSource _dataSource;

  @override
  Future<Result<DriverActivity>> getActivity() async {
    try {
      final model = await _dataSource.getActivity();
      return Result.ok(model.toDomain());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

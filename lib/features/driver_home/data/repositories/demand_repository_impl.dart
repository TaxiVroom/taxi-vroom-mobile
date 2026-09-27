import 'package:dio/dio.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/demand_remote_datasource.dart';
import 'package:mobile/features/driver_home/domain/entities/demand_overview.dart';
import 'package:mobile/features/driver_home/domain/repositories/demand_repository.dart';

class DemandRepositoryImpl implements DemandRepository {
  const DemandRepositoryImpl(this._dataSource);

  final DemandRemoteDataSource _dataSource;

  @override
  Future<Result<DemandOverview>> getDemand({
    required Coordinates around,
  }) async {
    try {
      final model = await _dataSource.getDemand(
        latitude: around.latitude,
        longitude: around.longitude,
      );
      return Result.ok(model.toDomain());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

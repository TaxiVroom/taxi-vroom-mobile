import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/data/datasources/nearby_taxi_remote_datasource.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';
import 'package:mobile/features/passenger_home/domain/repositories/nearby_taxi_repository.dart';

class NearbyTaxiRepositoryImpl implements NearbyTaxiRepository {
  const NearbyTaxiRepositoryImpl(this._dataSource);

  final NearbyTaxiRemoteDataSource _dataSource;

  @override
  Future<Result<List<NearbyTaxi>>> getNearbyTaxis({
    required Coordinates around,
  }) async {
    try {
      final models = await _dataSource.getNearbyTaxis(
        latitude: around.latitude,
        longitude: around.longitude,
      );
      return Result.ok(models.map((m) => m.toDomain()).toList());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

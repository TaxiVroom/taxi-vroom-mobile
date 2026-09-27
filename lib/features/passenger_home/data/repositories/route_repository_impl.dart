import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/data/datasources/route_remote_datasource.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_route.dart';
import 'package:mobile/features/passenger_home/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  const RouteRepositoryImpl(this._dataSource);

  final RouteRemoteDataSource _dataSource;

  @override
  Future<Result<RideRoute>> getRoute({
    required Coordinates from,
    required Coordinates to,
    DateTime? arriveBy,
  }) async {
    try {
      final models = await _dataSource.getRoutes(
        fromLatitude: from.latitude,
        fromLongitude: from.longitude,
        toLatitude: to.latitude,
        toLongitude: to.longitude,
        arriveBy: arriveBy,
      );
      if (models.isEmpty) {
        return const Result.error(ServerFailure('Aucun itinéraire trouvé'));
      }
      return Result.ok(models.first.toDomain());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/data/datasources/recent_destination_remote_datasource.dart';
import 'package:mobile/features/passenger_home/domain/entities/recent_destination.dart';
import 'package:mobile/features/passenger_home/domain/repositories/recent_destination_repository.dart';

class RecentDestinationRepositoryImpl implements RecentDestinationRepository {
  const RecentDestinationRepositoryImpl(this._dataSource);

  final RecentDestinationRemoteDataSource _dataSource;

  @override
  Future<Result<List<RecentDestination>>> getRecentDestinations() async {
    try {
      final models = await _dataSource.getRecentDestinations();
      return Result.ok(models.map((m) => m.toDomain()).toList());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

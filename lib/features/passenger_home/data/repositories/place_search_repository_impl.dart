import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/data/datasources/place_search_remote_datasource.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/place_suggestion.dart';
import 'package:mobile/features/passenger_home/domain/repositories/place_search_repository.dart';
import 'package:uuid/uuid.dart';

class PlaceSearchRepositoryImpl implements PlaceSearchRepository {
  PlaceSearchRepositoryImpl(this._dataSource);

  final PlaceSearchRemoteDataSource _dataSource;

  // Mapbox bills per session: every /suggest up to the /retrieve shares one
  // token, then a new session starts.
  String? _sessionToken;
  String get _currentSessionToken => _sessionToken ??= const Uuid().v4();

  @override
  Future<Result<List<PlaceSuggestion>>> suggest({
    required String query,
    required Coordinates near,
  }) async {
    try {
      final models = await _dataSource.suggest(
        query: query,
        latitude: near.latitude,
        longitude: near.longitude,
        sessionToken: _currentSessionToken,
      );
      return Result.ok(models.map((m) => m.toDomain()).toList());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<Place>> retrieve(PlaceSuggestion suggestion) async {
    try {
      final models = await _dataSource.retrieve(
        mapboxId: suggestion.id,
        sessionToken: _currentSessionToken,
      );
      _sessionToken = null;
      if (models.isEmpty) {
        return const Result.error(ServerFailure('Adresse introuvable'));
      }
      return Result.ok(models.first.toDomain());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

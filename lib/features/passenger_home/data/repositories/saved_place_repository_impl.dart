import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/data/datasources/saved_place_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/models/saved_place_model.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';
import 'package:mobile/features/passenger_home/domain/repositories/saved_place_repository.dart';

class SavedPlaceRepositoryImpl implements SavedPlaceRepository {
  const SavedPlaceRepositoryImpl(this._dataSource);

  final SavedPlaceRemoteDataSource _dataSource;

  @override
  Future<Result<List<SavedPlace>>> getSavedPlaces() async {
    try {
      final models = await _dataSource.getSavedPlaces();
      return Result.ok([for (final model in models) model.toDomain()]);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  @override
  Future<Result<SavedPlace>> add(SavedPlace place) =>
      _save(() => _dataSource.add(SavedPlaceModel.fromDomain(place)));

  @override
  Future<Result<SavedPlace>> change(SavedPlace place) =>
      _save(() => _dataSource.change(SavedPlaceModel.fromDomain(place)));

  @override
  Future<Result<void>> delete(SavedPlaceKind kind) async {
    try {
      await _dataSource.delete(kind);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }

  Future<Result<SavedPlace>> _save(
    Future<SavedPlaceModel> Function() request,
  ) async {
    try {
      return Result.ok((await request()).toDomain());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

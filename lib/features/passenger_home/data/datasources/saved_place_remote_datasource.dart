import 'package:dio/dio.dart';
import 'package:mobile/features/passenger_home/data/models/saved_place_model.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';

abstract class SavedPlaceRemoteDataSource {
  Future<List<SavedPlaceModel>> getSavedPlaces();

  Future<SavedPlaceModel> add(SavedPlaceModel place);

  Future<SavedPlaceModel> change(SavedPlaceModel place);

  Future<void> delete(SavedPlaceKind kind);
}

// "Maison" and "Travail" through the API, which keeps the address chosen
// from Mapbox as it is, like a ride's destination. Spec
// taxi-vroom-api/docs/specs/maison-et-travail.md.
class SavedPlaceRemoteDataSourceImpl implements SavedPlaceRemoteDataSource {
  const SavedPlaceRemoteDataSourceImpl(this._dio);

  static const _path = '/v1/me/saved-places';

  final Dio _dio;

  @override
  Future<List<SavedPlaceModel>> getSavedPlaces() async {
    final response = await _dio.get<List<dynamic>>(_path);
    return [
      for (final json in response.data!)
        SavedPlaceModel.fromJson(json as Map<String, dynamic>),
    ];
  }

  @override
  Future<SavedPlaceModel> add(SavedPlaceModel place) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _path,
      data: place.toJson(),
    );
    return SavedPlaceModel.fromJson(response.data!);
  }

  @override
  Future<SavedPlaceModel> change(SavedPlaceModel place) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '$_path/${SavedPlaceModel.kindToJson(place.kind)}',
      data: place.toLocationJson(),
    );
    return SavedPlaceModel.fromJson(response.data!);
  }

  @override
  Future<void> delete(SavedPlaceKind kind) =>
      _dio.delete<void>('$_path/${SavedPlaceModel.kindToJson(kind)}');
}

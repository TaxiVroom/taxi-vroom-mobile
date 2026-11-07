import 'package:dio/dio.dart';
import 'package:mobile/features/registration/driver/data/models/commune_model.dart';

abstract class CommuneRemoteDataSource {
  Future<List<CommuneModel>> searchCommunes(String name);
}

// The State's API Découpage administratif: free, no key. Parameters nom,
// boost=population (the big communes first) and fields.
// Docs: https://geo.api.gouv.fr/decoupage-administratif/communes
class CommuneRemoteDataSourceImpl implements CommuneRemoteDataSource {
  const CommuneRemoteDataSourceImpl(this._dio);

  // Points to https://geo.api.gouv.fr, without the backend's auth
  // interceptor.
  final Dio _dio;

  static const _shown = 5;

  @override
  Future<List<CommuneModel>> searchCommunes(String name) async {
    final response = await _dio.get<List<dynamic>>(
      '/communes',
      queryParameters: {
        'nom': name,
        'boost': 'population',
        'fields': 'nom,code,codeDepartement',
      },
    );
    // The page does not document a limit parameter: the list is cut here.
    return response.data!
        .take(_shown)
        .map((json) => CommuneModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

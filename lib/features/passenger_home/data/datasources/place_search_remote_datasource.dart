import 'package:dio/dio.dart';
import 'package:mobile/features/passenger_home/data/models/place_model.dart';
import 'package:mobile/features/passenger_home/data/models/place_suggestion_model.dart';

abstract class PlaceSearchRemoteDataSource {
  Future<List<PlaceSuggestionModel>> suggest({
    required String query,
    required double latitude,
    required double longitude,
    required String sessionToken,
  });

  Future<List<PlaceModel>> retrieve({
    required String mapboxId,
    required String sessionToken,
  });

  // The address at a point; empty when there is none.
  Future<List<PlaceModel>> reverse({
    required double latitude,
    required double longitude,
  });
}

// Mapbox Search Box API: https://docs.mapbox.com/api/search/search-box/
class PlaceSearchRemoteDataSourceImpl implements PlaceSearchRemoteDataSource {
  const PlaceSearchRemoteDataSourceImpl(
    this._dio, {
    required String accessToken,
  }) : _accessToken = accessToken;

  // Points to https://api.mapbox.com, without the backend's auth interceptor.
  final Dio _dio;
  final String _accessToken;

  @override
  Future<List<PlaceSuggestionModel>> suggest({
    required String query,
    required double latitude,
    required double longitude,
    required String sessionToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/search/searchbox/v1/suggest',
      queryParameters: {
        'q': query,
        'session_token': sessionToken,
        'access_token': _accessToken,
        'language': 'fr',
        'country': 'fr',
        'proximity': '$longitude,$latitude',
        'limit': 5,
      },
    );
    return (response.data!['suggestions'] as List<dynamic>)
        .map((e) => PlaceSuggestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PlaceModel>> retrieve({
    required String mapboxId,
    required String sessionToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/search/searchbox/v1/retrieve/$mapboxId',
      queryParameters: {
        'session_token': sessionToken,
        'access_token': _accessToken,
        'language': 'fr',
      },
    );
    return _places(response);
  }

  // Billed per request, outside the /suggest sessions.
  @override
  Future<List<PlaceModel>> reverse({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/search/searchbox/v1/reverse',
      queryParameters: {
        'longitude': longitude,
        'latitude': latitude,
        'access_token': _accessToken,
        'language': 'fr',
        'country': 'fr',
        'types': 'address',
        'limit': 1,
      },
    );
    return _places(response);
  }

  List<PlaceModel> _places(Response<Map<String, dynamic>> response) =>
      (response.data!['features'] as List<dynamic>)
          .map((e) => PlaceModel.fromJson(e as Map<String, dynamic>))
          .toList();
}

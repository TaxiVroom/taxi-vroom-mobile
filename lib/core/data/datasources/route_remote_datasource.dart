import 'package:dio/dio.dart';
import 'package:mobile/core/data/models/navigation_route_model.dart';
import 'package:mobile/core/data/models/ride_route_model.dart';

abstract class RouteRemoteDataSource {
  Future<List<RideRouteModel>> getRoutes({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
    DateTime? arriveBy,
  });

  // Same, with the turn-by-turn steps to guide a driver.
  Future<List<NavigationRouteModel>> getNavigationRoutes({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  });
}

// Mapbox Directions API: https://docs.mapbox.com/api/navigation/directions/
class RouteRemoteDataSourceImpl implements RouteRemoteDataSource {
  const RouteRemoteDataSourceImpl(
    this._dio, {
    required String accessToken,
  }) : _accessToken = accessToken;

  // Points to https://api.mapbox.com, without the backend's auth interceptor.
  final Dio _dio;
  final String _accessToken;

  @override
  Future<List<RideRouteModel>> getRoutes({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
    DateTime? arriveBy,
  }) async {
    // Coordinates are "{longitude},{latitude}" pairs separated by ";".
    final coordinates = '$fromLongitude,$fromLatitude;$toLongitude,$toLatitude';
    // `arrive_by` is only supported by the `driving` profile: the duration is
    // then predicted from historical traffic, not live traffic.
    final profile = arriveBy == null ? 'driving-traffic' : 'driving';
    final response = await _dio.get<Map<String, dynamic>>(
      '/directions/v5/mapbox/$profile/$coordinates',
      queryParameters: {
        'access_token': _accessToken,
        'geometries': 'geojson',
        'overview': 'full',
        if (arriveBy != null) 'arrive_by': _toMapboxTime(arriveBy),
      },
    );
    return (response.data!['routes'] as List<dynamic>)
        .map((e) => RideRouteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<NavigationRouteModel>> getNavigationRoutes({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) async {
    final coordinates = '$fromLongitude,$fromLatitude;$toLongitude,$toLatitude';
    final response = await _dio.get<Map<String, dynamic>>(
      '/directions/v5/mapbox/driving-traffic/$coordinates',
      queryParameters: {
        'access_token': _accessToken,
        'geometries': 'geojson',
        'overview': 'full',
        'steps': true,
      },
    );
    return (response.data!['routes'] as List<dynamic>)
        .map((e) => NavigationRouteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ISO 8601 "YYYY-MM-DDThh:mm:ssZ", in UTC: Mapbox rejects milliseconds.
  String _toMapboxTime(DateTime time) =>
      '${time.toUtc().toIso8601String().substring(0, 19)}Z';
}

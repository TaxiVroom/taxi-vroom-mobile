import 'package:dio/dio.dart';
import 'package:mobile/features/passenger_home/data/models/address_model.dart';

abstract class AddressRemoteDataSource {
  // Null when no address is known there, as outside France.
  Future<AddressModel?> findAddress({
    required double latitude,
    required double longitude,
  });
}

// The State's reverse geocoding, on the Base Adresse Nationale: free, no
// key, 50 requests per second per IP, open licence. The backend names the
// pickup it keeps with the same service, so the passenger sees that name.
// Parameters: https://data.geopf.fr/geocodage/getCapabilities
// Limits: https://cartes.gouv.fr/aide/fr/guides-utilisateur/utiliser-les-services-de-la-geoplateforme/geocodage/
class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  const AddressRemoteDataSourceImpl(this._dio);

  // Points to https://data.geopf.fr, without the backend's auth interceptor.
  final Dio _dio;

  @override
  Future<AddressModel?> findAddress({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/geocodage/reverse',
      queryParameters: {
        'lon': longitude,
        'lat': latitude,
        'index': 'address',
        'limit': 1,
      },
    );
    final features = response.data!['features'] as List<dynamic>;
    if (features.isEmpty) return null;
    return AddressModel.fromJson(features.first as Map<String, dynamic>);
  }
}

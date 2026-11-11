import 'package:dio/dio.dart';

abstract class EnterpriseContactRemoteDataSource {
  Future<String> getPhone();
}

// GET /v1/enterprise-contact, e.g. {"phone":"+33612345678"}: the number
// lives in the API's environment, never in the app. Spec
// taxi-vroom-api/docs/specs/aide-chauffeur.md.
class EnterpriseContactRemoteDataSourceImpl
    implements EnterpriseContactRemoteDataSource {
  const EnterpriseContactRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<String> getPhone() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/enterprise-contact',
    );
    return response.data!['phone'] as String;
  }
}

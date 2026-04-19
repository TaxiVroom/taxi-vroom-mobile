import 'package:dio/dio.dart';

abstract class EmailAvailabilityRemoteDataSource {
  Future<bool> checkEmailAvailability({required String email});
}

class EmailAvailabilityRemoteDataSourceImpl implements EmailAvailabilityRemoteDataSource {
  const EmailAvailabilityRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<bool> checkEmailAvailability({required String email}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/registration-flows/me/email-availability',
      queryParameters: {'email': email},
    );
    return response.data!['isAvailable'] as bool;
  }
}

/// Implémentation de développement avec données de test.
/// À remplacer par [EmailAvailabilityRemoteDataSourceImpl] lorsque le backend est prêt.
class EmailAvailabilityRemoteDataSourceFake implements EmailAvailabilityRemoteDataSource {
  static const _takenEmails = {'taken@example.com', 'test@test.com'};

  @override
  Future<bool> checkEmailAvailability({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return !_takenEmails.contains(email.toLowerCase().trim());
  }
}

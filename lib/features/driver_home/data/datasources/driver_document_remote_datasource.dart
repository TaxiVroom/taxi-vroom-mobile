import 'package:dio/dio.dart';
import 'package:mobile/features/driver_home/data/models/driver_document_model.dart';

// The driver's documents and going online. Spec
// taxi-vroom-api/docs/specs/documents-du-chauffeur.md.
abstract class DriverDocumentRemoteDataSource {
  Future<List<DriverDocumentModel>> getDocuments();

  // "Passer en ligne": the API checks the documents, then allows the
  // presence in Firebase. 409 DRIVER.DOCUMENTS_BLOCKING otherwise.
  Future<void> allowOnline();

  Future<void> submitDocument({
    required String documentTypeId,
    required String frontFilePath,
    String? backFilePath,
    DateTime? expiresAt,
  });
}

class DriverDocumentRemoteDataSourceImpl
    implements DriverDocumentRemoteDataSource {
  const DriverDocumentRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<DriverDocumentModel>> getDocuments() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/drivers/me/documents',
    );
    return (response.data!['documents'] as List<dynamic>)
        .map(
          (json) => DriverDocumentModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> allowOnline() => _dio.post<void>('/v1/drivers/me/online');

  @override
  Future<void> submitDocument({
    required String documentTypeId,
    required String frontFilePath,
    String? backFilePath,
    DateTime? expiresAt,
  }) async {
    final formData = FormData.fromMap({
      'front': await MultipartFile.fromFile(frontFilePath),
      if (backFilePath != null)
        'back': await MultipartFile.fromFile(backFilePath),
      // A day, without the time.
      if (expiresAt != null)
        'expiresAt': expiresAt.toIso8601String().substring(0, 10),
    });
    await _dio.post<void>(
      '/v1/drivers/me/documents/$documentTypeId',
      data: formData,
    );
  }
}

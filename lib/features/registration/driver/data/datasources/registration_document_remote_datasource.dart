import 'package:dio/dio.dart';
import 'package:mobile/features/registration/driver/data/models/document_type_model.dart';
import 'package:mobile/features/registration/driver/data/models/registration_document_model.dart';

abstract class RegistrationDocumentRemoteDataSource {
  Future<List<DocumentTypeModel>> getDocumentTypes();

  Future<void> uploadDocument({
    required String documentTypeId,
    String? frontFilePath,
    String? backFilePath,
  });

  Future<List<RegistrationDocumentModel>> getUploadedDocuments();

  Future<String> getDocumentSignedUrl({
    required String documentTypeId,
    required String side,
  });
}

class RegistrationDocumentRemoteDataSourceImpl
    implements RegistrationDocumentRemoteDataSource {
  const RegistrationDocumentRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<DocumentTypeModel>> getDocumentTypes() async {
    final response =
        await _dio.get<List<dynamic>>('/v1/registration-document-types');
    return response.data!
        .map((e) => DocumentTypeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> uploadDocument({
    required String documentTypeId,
    String? frontFilePath,
    String? backFilePath,
  }) async {
    final formData = FormData.fromMap({
      'documentTypeId': documentTypeId,
      if (frontFilePath != null) 'front': await MultipartFile.fromFile(frontFilePath),
      if (backFilePath != null) 'back': await MultipartFile.fromFile(backFilePath),
    });
    await _dio.post<void>('/v1/registration-flows/me/documents', data: formData);
  }

  @override
  Future<List<RegistrationDocumentModel>> getUploadedDocuments() async {
    final response =
        await _dio.get<List<dynamic>>('/v1/registration-flows/me/documents');
    return response.data!
        .map((e) => RegistrationDocumentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> getDocumentSignedUrl({
    required String documentTypeId,
    required String side,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/registration-flows/me/documents/$documentTypeId/url',
      queryParameters: {'side': side},
    );
    return response.data!['url'] as String;
  }
}

import 'package:mobile/features/registration/driver/data/datasources/registration_document_remote_datasource.dart';
import 'package:mobile/features/registration/driver/domain/entities/document_type.dart';
import 'package:mobile/features/registration/driver/domain/entities/registration_document.dart';
import 'package:mobile/features/registration/driver/domain/repositories/registration_document_repository.dart';

class RegistrationDocumentRepositoryImpl
    implements RegistrationDocumentRepository {
  const RegistrationDocumentRepositoryImpl(this._dataSource);

  final RegistrationDocumentRemoteDataSource _dataSource;

  @override
  Future<List<DocumentType>> getDocumentTypes() async {
    final models = await _dataSource.getDocumentTypes();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<void> uploadDocument({
    required String documentTypeId,
    String? frontFilePath,
    String? backFilePath,
    DateTime? expiresAt,
  }) => _dataSource.uploadDocument(
    documentTypeId: documentTypeId,
    frontFilePath: frontFilePath,
    backFilePath: backFilePath,
    expiresAt: expiresAt,
  );

  @override
  Future<List<RegistrationDocument>> getUploadedDocuments() async {
    final models = await _dataSource.getUploadedDocuments();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<String> getDocumentSignedUrl({
    required String documentTypeId,
    required String side,
  }) => _dataSource.getDocumentSignedUrl(
    documentTypeId: documentTypeId,
    side: side,
  );
}

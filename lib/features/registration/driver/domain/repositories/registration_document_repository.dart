import 'package:mobile/features/registration/driver/domain/entities/document_type.dart';
import 'package:mobile/features/registration/driver/domain/entities/registration_document.dart';

abstract class RegistrationDocumentRepository {
  Future<List<DocumentType>> getDocumentTypes();

  Future<void> uploadDocument({
    required String documentTypeId,
    String? frontFilePath,
    String? backFilePath,
  });

  Future<List<RegistrationDocument>> getUploadedDocuments();

  Future<String> getDocumentSignedUrl({
    required String documentTypeId,
    required String side,
  });
}

import 'package:mobile/features/registration/driver/domain/repositories/registration_document_repository.dart';

class UploadRegistrationDocumentUseCase {
  const UploadRegistrationDocumentUseCase(this._repository);

  final RegistrationDocumentRepository _repository;

  Future<void> call({
    required String documentTypeId,
    String? frontFilePath,
    String? backFilePath,
  }) =>
      _repository.uploadDocument(
        documentTypeId: documentTypeId,
        frontFilePath: frontFilePath,
        backFilePath: backFilePath,
      );
}

import 'package:mobile/features/registration/driver/domain/repositories/registration_document_repository.dart';

class GetDocumentSignedUrlUseCase {
  const GetDocumentSignedUrlUseCase(this._repository);

  final RegistrationDocumentRepository _repository;

  Future<String> call({
    required String documentTypeId,
    required String side,
  }) =>
      _repository.getDocumentSignedUrl(
        documentTypeId: documentTypeId,
        side: side,
      );
}

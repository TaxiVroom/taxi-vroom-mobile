import 'package:mobile/features/registration/driver/domain/entities/registration_document.dart';
import 'package:mobile/features/registration/driver/domain/repositories/registration_document_repository.dart';

class GetUploadedDocumentsUseCase {
  const GetUploadedDocumentsUseCase(this._repository);

  final RegistrationDocumentRepository _repository;

  Future<List<RegistrationDocument>> call() => _repository.getUploadedDocuments();
}

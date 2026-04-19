import 'package:mobile/features/registration/driver/domain/entities/document_type.dart';
import 'package:mobile/features/registration/driver/domain/repositories/registration_document_repository.dart';

class GetDocumentTypesUseCase {
  const GetDocumentTypesUseCase(this._repository);

  final RegistrationDocumentRepository _repository;

  Future<List<DocumentType>> call() => _repository.getDocumentTypes();
}

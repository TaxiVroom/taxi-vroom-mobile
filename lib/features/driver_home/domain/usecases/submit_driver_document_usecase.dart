import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_document_repository.dart';

// "Renouveler" or "Envoyer": the new document waits for the admin, the
// valid one stays until then. Spec
// taxi-vroom-api/docs/specs/documents-du-chauffeur.md.
class SubmitDriverDocumentUseCase {
  const SubmitDriverDocumentUseCase(this._repository);

  final DriverDocumentRepository _repository;

  Future<Result<void>> call({
    required String documentTypeId,
    required String frontFilePath,
    String? backFilePath,
    DateTime? expiresAt,
  }) => _repository.submitDocument(
    documentTypeId: documentTypeId,
    frontFilePath: frontFilePath,
    backFilePath: backFilePath,
    expiresAt: expiresAt,
  );
}

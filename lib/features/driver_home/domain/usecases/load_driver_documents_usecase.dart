import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_document_repository.dart';

// Checked at login: an expired document or a new required one must be sent.
class LoadDriverDocumentsUseCase {
  const LoadDriverDocumentsUseCase(this._driverDocumentRepository);

  final DriverDocumentRepository _driverDocumentRepository;

  Future<Result<DriverDocuments>> call() =>
      _driverDocumentRepository.getDocuments();
}

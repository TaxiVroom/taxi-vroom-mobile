import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';

abstract class DriverDocumentRepository {
  Future<Result<DriverDocuments>> getDocuments();

  // Before going online: refused with DocumentsBlockingFailure.
  Future<Result<void>> allowOnline();

  // A renewed or new document, waiting for the admin.
  Future<Result<void>> submitDocument({
    required String documentTypeId,
    required String frontFilePath,
    String? backFilePath,
    DateTime? expiresAt,
  });
}

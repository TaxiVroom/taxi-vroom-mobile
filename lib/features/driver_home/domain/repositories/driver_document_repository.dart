import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';

abstract class DriverDocumentRepository {
  Future<Result<DriverDocuments>> getDocuments();
}

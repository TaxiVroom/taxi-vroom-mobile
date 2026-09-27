import 'package:mobile/features/driver_home/data/models/driver_document_model.dart';

// No backend endpoint yet: only the fake implementation exists.
abstract class DriverDocumentRemoteDataSource {
  Future<List<DriverDocumentModel>> getDocuments();
}

import 'package:mobile/features/registration/driver/data/datasources/registration_document_remote_datasource.dart';
import 'package:mobile/features/registration/driver/data/models/document_type_model.dart';
import 'package:mobile/features/registration/driver/data/models/registration_document_model.dart';

/// Implémentation de développement avec données de test.
/// À remplacer par [RegistrationDocumentRemoteDataSourceImpl] lorsque le backend est prêt.
class RegistrationDocumentRemoteDataSourceFake
    implements RegistrationDocumentRemoteDataSource {
  static const _fakeDocumentTypeIdIdentity = 'fake-id-carte-identite';
  static const _fakeDocumentTypeIdProTaxi = 'fake-id-carte-pro-taxi';
  static const _fakeDocumentTypeIdGrise = 'fake-id-carte-grise';

  @override
  Future<List<DocumentTypeModel>> getDocumentTypes() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const [
      DocumentTypeModel(
        id: _fakeDocumentTypeIdIdentity,
        name: "Carte d'identité",
        backRequired: true,
        expires: true,
      ),
      DocumentTypeModel(
        id: _fakeDocumentTypeIdProTaxi,
        name: 'Carte Pro Taxi',
        backRequired: true,
        expires: true,
      ),
      DocumentTypeModel(
        id: _fakeDocumentTypeIdGrise,
        name: 'Carte grise',
        backRequired: false,
        expires: false,
      ),
    ];
  }

  @override
  Future<void> uploadDocument({
    required String documentTypeId,
    String? frontFilePath,
    String? backFilePath,
    DateTime? expiresAt,
  }) => Future<void>.delayed(const Duration(milliseconds: 600));

  @override
  Future<List<RegistrationDocumentModel>> getUploadedDocuments() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const [
      ValidatedRegistrationDocumentModel(
        documentTypeId: _fakeDocumentTypeIdIdentity,
      ),
      RejectedRegistrationDocumentModel(
        documentTypeId: _fakeDocumentTypeIdProTaxi,
        reason:
            'La photo du verso est trop floue. '
            'On ne parvient pas à lire la date de fin de validité.',
      ),
      ValidatedRegistrationDocumentModel(
        documentTypeId: _fakeDocumentTypeIdGrise,
      ),
    ];
  }

  @override
  Future<String> getDocumentSignedUrl({
    required String documentTypeId,
    required String side,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return 'https://fake-signed-url.example.com/$documentTypeId/$side';
  }
}

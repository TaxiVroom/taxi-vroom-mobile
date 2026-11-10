import 'package:mobile/features/driver_home/data/datasources/driver_document_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/models/driver_document_model.dart';

/// Development implementation with test data.
///
/// [hasDocumentToRenew]: true, the professional card is to renew and the
/// home shows its banner; false, everything is valid.
class DriverDocumentRemoteDataSourceFake
    implements DriverDocumentRemoteDataSource {
  DriverDocumentRemoteDataSourceFake({required this.hasDocumentToRenew});

  final bool hasDocumentToRenew;

  @override
  Future<List<DriverDocumentModel>> getDocuments() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return [
      _document(
        'Carte professionnelle de taxi',
        hasDocumentToRenew ? 'TO_RENEW' : 'VALID',
        expiresAt: DateTime.now().add(const Duration(days: 20)),
      ),
      _document(
        'Permis de conduire',
        'VALID',
        expiresAt: DateTime.now().add(const Duration(days: 900)),
      ),
      _document('Carte grise', 'VALID', expires: false),
    ];
  }

  @override
  Future<void> allowOnline() async {}

  @override
  Future<void> submitDocument({
    required String documentTypeId,
    required String frontFilePath,
    String? backFilePath,
    DateTime? expiresAt,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  DriverDocumentModel _document(
    String name,
    String state, {
    bool expires = true,
    DateTime? expiresAt,
  }) => DriverDocumentModel(
    documentTypeId: name,
    name: name,
    backRequired: true,
    expires: expires,
    state: state,
    expiresAt: expiresAt?.toIso8601String(),
    lastValidDay: expiresAt?.toIso8601String().substring(0, 10),
    requiredFrom: null,
    inReview: false,
  );
}

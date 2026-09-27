import 'package:mobile/features/driver_home/data/datasources/driver_document_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/models/driver_document_model.dart';

/// Implémentation de développement avec données de test.
///
/// [hasDocumentToRenew] : à true, le taximètre est à renouveler et l'écran
/// « Vos documents » s'affiche à la connexion ; à false, tout est validé et
/// le chauffeur arrive directement sur l'accueil.
class DriverDocumentRemoteDataSourceFake
    implements DriverDocumentRemoteDataSource {
  DriverDocumentRemoteDataSourceFake({required this.hasDocumentToRenew});

  final bool hasDocumentToRenew;

  @override
  Future<List<DriverDocumentModel>> getDocuments() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return [
      _document(
        kind: 'professionalCard',
        name: 'Carte professionnelle',
        detail: 'Conducteur de taxi, Bas-Rhin',
        proofName: 'la carte professionnelle',
      ),
      _document(
        kind: 'parkingPermit',
        name: 'Autorisation de stationnement',
        detail: 'ADS n° 118, Strasbourg',
        proofName: "l'autorisation de stationnement",
      ),
      _document(
        kind: 'drivingLicence',
        name: 'Permis de conduire',
        detail: 'Catégorie B',
        proofName: 'le permis de conduire',
      ),
      _document(
        kind: 'vehicle',
        name: 'Carte grise et assurance',
        detail: 'GH-482-KZ, Corolla Touring',
        proofName: "la carte grise et l'assurance",
      ),
      _document(
        kind: 'taximeter',
        name: 'Taximètre',
        detail: hasDocumentToRenew
            ? 'Vérification annuelle avant le 12 oct.'
            : 'Vérifié le 12 oct. 2025',
        proofName: 'le certificat du taximètre',
        status: hasDocumentToRenew ? 'expiringSoon' : 'validated',
      ),
      _document(
        kind: 'paymentTerminal',
        name: 'Terminal CB et imprimante',
        detail: 'Obligatoires à bord',
        proofName: 'la preuve du terminal CB',
      ),
    ];
  }

  DriverDocumentModel _document({
    required String kind,
    required String name,
    required String detail,
    required String proofName,
    String status = 'validated',
  }) => DriverDocumentModel.fromJson({
    'kind': kind,
    'name': name,
    'detail': detail,
    'status': status,
    'proofName': proofName,
  });
}

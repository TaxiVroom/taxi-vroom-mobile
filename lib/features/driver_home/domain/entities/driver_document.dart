import 'package:equatable/equatable.dart';

enum DriverDocumentKind {
  professionalCard,
  parkingPermit,
  drivingLicence,
  vehicle,
  taximeter,
  paymentTerminal,
}

enum DriverDocumentStatus {
  validated,

  // Still valid, but must be renewed soon.
  expiringSoon,

  expired,

  // Never sent, e.g. required by a new law.
  missing,
}

// A document a taxi driver must keep valid to drive.
class DriverDocument extends Equatable {
  const DriverDocument({
    required this.kind,
    required this.name,
    required this.detail,
    required this.status,
    required this.proofName,
  });

  final DriverDocumentKind kind;

  // E.g. "Taximètre".
  final String name;

  // E.g. "Vérification annuelle avant le 12 oct.".
  final String detail;

  final DriverDocumentStatus status;

  // What the driver sends, e.g. "le certificat du taximètre".
  final String proofName;

  bool get needsAction => status != DriverDocumentStatus.validated;

  // Driving without a valid document is not allowed.
  bool get blocksDriving =>
      status == DriverDocumentStatus.expired ||
      status == DriverDocumentStatus.missing;

  @override
  List<Object?> get props => [kind, name, detail, status, proofName];
}

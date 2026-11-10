import 'package:mobile/features/driver_home/domain/entities/driver_document.dart';

// One document type of the driver, from GET /v1/drivers/me/documents.
class DriverDocumentModel {
  const DriverDocumentModel({
    required this.documentTypeId,
    required this.name,
    required this.backRequired,
    required this.expires,
    required this.state,
    required this.expiresAt,
    required this.lastValidDay,
    required this.requiredFrom,
    required this.inReview,
  });

  factory DriverDocumentModel.fromJson(Map<String, dynamic> json) =>
      DriverDocumentModel(
        documentTypeId: json['documentTypeId'] as String,
        name: json['name'] as String,
        backRequired: json['backRequired'] as bool,
        expires: json['expires'] as bool,
        state: json['state'] as String,
        expiresAt: json['expiresAt'] as String?,
        lastValidDay: json['lastValidDay'] as String?,
        requiredFrom: json['requiredFrom'] as String?,
        inReview: json['inReview'] as bool,
      );

  final String documentTypeId;
  final String name;
  final bool backRequired;
  final bool expires;
  // VALID, TO_RENEW, EXPIRED, TO_PROVIDE or MISSING.
  final String state;
  final String? expiresAt;
  // "2027-03-11".
  final String? lastValidDay;
  final String? requiredFrom;
  final bool inReview;

  DriverDocument toDomain() => DriverDocument(
    documentTypeId: documentTypeId,
    name: name,
    backRequired: backRequired,
    expires: expires,
    status: switch (state) {
      'TO_RENEW' => DriverDocumentStatus.expiringSoon,
      'EXPIRED' => DriverDocumentStatus.expired,
      'TO_PROVIDE' => DriverDocumentStatus.toProvide,
      'MISSING' => DriverDocumentStatus.missing,
      _ => DriverDocumentStatus.validated,
    },
    expiresAt: _date(expiresAt),
    lastValidDay: _date(lastValidDay),
    requiredFrom: _date(requiredFrom),
    inReview: inReview,
  );

  DateTime? _date(String? iso) => iso == null ? null : DateTime.parse(iso);
}

import 'package:mobile/features/driver_home/domain/entities/driver_document.dart';

// One document type of the driver, from GET /v1/drivers/me/documents or the
// "documents" of GET /v1/drivers/me/account.
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

  // The {"documents": [...], "isBlocked", "inOrderUntil"} object both routes
  // answer.
  static List<DriverDocumentModel> listFromJson(Map<String, dynamic> json) =>
      (json['documents'] as List<dynamic>)
          .map(
            (json) =>
                DriverDocumentModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

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

import 'package:equatable/equatable.dart';

enum DriverDocumentStatus {
  validated,

  // Still valid, but must be renewed soon.
  expiringSoon,

  expired,

  // A new type, before its deadline: driving still allowed.
  toProvide,

  // Never sent, e.g. required by a new law, past its deadline.
  missing,
}

// A document a taxi driver must keep valid to drive, as the API tells its
// state. Spec taxi-vroom-api/docs/specs/documents-du-chauffeur.md.
class DriverDocument extends Equatable {
  const DriverDocument({
    required this.documentTypeId,
    required this.name,
    required this.backRequired,
    required this.expires,
    required this.status,
    required this.expiresAt,
    required this.lastValidDay,
    required this.requiredFrom,
    required this.inReview,
  });

  final String documentTypeId;

  // E.g. "Carte professionnelle de taxi".
  final String name;

  final bool backRequired;

  // Its date of end of validity is asked when it is sent.
  final bool expires;

  final DriverDocumentStatus status;

  // The end of validity: the day after the last valid day, at 00:00 in
  // Paris.
  final DateTime? expiresAt;

  // The last day it is valid, as written on it, e.g. 11 March 2027.
  final DateTime? lastValidDay;

  // A new type's deadline.
  final DateTime? requiredFrom;

  // A new one was sent and waits for the admin.
  final bool inReview;

  bool get needsAction => status != DriverDocumentStatus.validated;

  // Driving without a valid document is not allowed.
  bool get blocksDriving =>
      status == DriverDocumentStatus.expired ||
      status == DriverDocumentStatus.missing;

  // From when it no longer lets the driver work: its end of validity, or a
  // new type's deadline. Null: no end.
  DateTime? get endsAt => switch (status) {
    DriverDocumentStatus.toProvide => requiredFrom,
    DriverDocumentStatus.missing => null,
    _ => expiresAt,
  };

  @override
  List<Object?> get props => [
    documentTypeId,
    name,
    backRequired,
    expires,
    status,
    expiresAt,
    lastValidDay,
    requiredFrom,
    inReview,
  ];
}

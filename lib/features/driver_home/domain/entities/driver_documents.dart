import 'package:equatable/equatable.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_document.dart';

// All the documents of the driver. Spec
// taxi-vroom-api/docs/specs/documents-du-chauffeur.md.
class DriverDocuments extends Equatable {
  const DriverDocuments(this.documents);

  final List<DriverDocument> documents;

  int get validatedCount =>
      documents.where((document) => !document.needsAction).length;

  // Shown at login when true.
  bool get needsAction => documents.any((document) => document.needsAction);

  // True: no "Plus tard", the driver must send the document before driving.
  bool get blocksDriving => documents.any((document) => document.blocksDriving);

  // "Vos documents" opens on arrival when true: a document waiting for the
  // admin leaves the driver nothing to do (decision of the user,
  // 2026-11-11).
  bool get hasDocumentToSend => nextToProvide != null;

  // The document to send first: a blocking one before one expiring soon,
  // never one already waiting for the admin.
  DriverDocument? get nextToProvide {
    final toSend = documents.where((document) => !document.inReview);
    return toSend.where((document) => document.blocksDriving).firstOrNull ??
        toSend.where((document) => document.needsAction).firstOrNull;
  }

  // The document that ends first: the bookings after its date are not
  // offered, even while a new one waits for the admin. Spec
  // taxi-vroom-api/docs/specs/documents-du-chauffeur.md.
  DriverDocument? get soonestEnd {
    DriverDocument? soonest;
    for (final document in documents) {
      final end = document.endsAt;
      if (end == null) continue;
      final soonestAt = soonest?.endsAt;
      if (soonestAt == null || end.isBefore(soonestAt)) soonest = document;
    }
    return soonest;
  }

  @override
  List<Object?> get props => [documents];
}

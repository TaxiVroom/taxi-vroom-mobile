import 'package:equatable/equatable.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_document.dart';

// All the documents of the driver, checked when they log in.
class DriverDocuments extends Equatable {
  const DriverDocuments(this.documents);

  final List<DriverDocument> documents;

  int get validatedCount =>
      documents.where((document) => !document.needsAction).length;

  // Shown at login when true.
  bool get needsAction => documents.any((document) => document.needsAction);

  // True: no "Plus tard", the driver must send the document before driving.
  bool get blocksDriving => documents.any((document) => document.blocksDriving);

  // The document to send first: a blocking one before one expiring soon.
  DriverDocument? get nextToProvide =>
      documents.where((document) => document.blocksDriving).firstOrNull ??
      documents.where((document) => document.needsAction).firstOrNull;

  @override
  List<Object?> get props => [documents];
}

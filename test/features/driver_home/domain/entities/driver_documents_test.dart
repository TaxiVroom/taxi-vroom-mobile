import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_document.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';

DriverDocument _document(
  DriverDocumentKind kind,
  DriverDocumentStatus status,
) => DriverDocument(
  kind: kind,
  name: kind.name,
  detail: '',
  status: status,
  proofName: kind.name,
);

void main() {
  group('DriverDocuments', () {
    test('all validated: nothing to do at login', () {
      // Arrange
      final documents = DriverDocuments([
        _document(
          DriverDocumentKind.professionalCard,
          DriverDocumentStatus.validated,
        ),
        _document(DriverDocumentKind.taximeter, DriverDocumentStatus.validated),
      ]);

      // Act
      final needsAction = documents.needsAction;

      // Assert
      expect(needsAction, isFalse);
    });

    test('expiring soon: shown at login, driving still allowed', () {
      // Arrange
      final documents = DriverDocuments([
        _document(
          DriverDocumentKind.professionalCard,
          DriverDocumentStatus.validated,
        ),
        _document(
          DriverDocumentKind.taximeter,
          DriverDocumentStatus.expiringSoon,
        ),
      ]);

      // Act
      final (needsAction, blocksDriving) = (
        documents.needsAction,
        documents.blocksDriving,
      );

      // Assert
      expect(needsAction, isTrue);
      expect(blocksDriving, isFalse);
    });

    test('expired: driving blocked', () {
      // Arrange
      final documents = DriverDocuments([
        _document(
          DriverDocumentKind.drivingLicence,
          DriverDocumentStatus.expired,
        ),
      ]);

      // Act
      final blocksDriving = documents.blocksDriving;

      // Assert
      expect(blocksDriving, isTrue);
    });

    test('missing, e.g. required by a new law: driving blocked', () {
      // Arrange
      final documents = DriverDocuments([
        _document(
          DriverDocumentKind.paymentTerminal,
          DriverDocumentStatus.missing,
        ),
      ]);

      // Act
      final blocksDriving = documents.blocksDriving;

      // Assert
      expect(blocksDriving, isTrue);
    });

    test('asks for the blocking document before the one expiring soon', () {
      // Arrange
      final documents = DriverDocuments([
        _document(
          DriverDocumentKind.taximeter,
          DriverDocumentStatus.expiringSoon,
        ),
        _document(
          DriverDocumentKind.drivingLicence,
          DriverDocumentStatus.expired,
        ),
      ]);

      // Act
      final nextToProvide = documents.nextToProvide;

      // Assert
      expect(nextToProvide?.kind, DriverDocumentKind.drivingLicence);
    });

    test('counts the validated documents', () {
      // Arrange
      final documents = DriverDocuments([
        _document(
          DriverDocumentKind.professionalCard,
          DriverDocumentStatus.validated,
        ),
        _document(
          DriverDocumentKind.taximeter,
          DriverDocumentStatus.expiringSoon,
        ),
      ]);

      // Act
      final validatedCount = documents.validatedCount;

      // Assert
      expect(validatedCount, 1);
    });
  });
}

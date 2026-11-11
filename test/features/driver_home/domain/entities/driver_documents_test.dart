import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_document.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_documents.dart';

DriverDocument _document(
  String name,
  DriverDocumentStatus status, {
  bool inReview = false,
  DateTime? expiresAt,
  DateTime? requiredFrom,
}) => DriverDocument(
  documentTypeId: name,
  name: name,
  backRequired: false,
  expires: true,
  status: status,
  expiresAt: expiresAt,
  lastValidDay: expiresAt,
  requiredFrom: requiredFrom,
  inReview: inReview,
);

void main() {
  group('DriverDocuments', () {
    test('all validated: nothing to do', () {
      // Arrange
      final documents = DriverDocuments([
        _document('Carte professionnelle', DriverDocumentStatus.validated),
        _document('Permis', DriverDocumentStatus.validated),
      ]);

      // Act
      final needsAction = documents.needsAction;

      // Assert
      expect(needsAction, isFalse);
    });

    test('expiring soon: to do, driving still allowed', () {
      // Arrange
      final documents = DriverDocuments([
        _document('Carte professionnelle', DriverDocumentStatus.validated),
        _document('Permis', DriverDocumentStatus.expiringSoon),
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

    test('a new type before its deadline: to do, driving still allowed', () {
      // Arrange
      final documents = DriverDocuments([
        _document('Contrôle technique', DriverDocumentStatus.toProvide),
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
        _document('Permis', DriverDocumentStatus.expired),
      ]);

      // Act
      final blocksDriving = documents.blocksDriving;

      // Assert
      expect(blocksDriving, isTrue);
    });

    test('missing, e.g. required by a new law: driving blocked', () {
      // Arrange
      final documents = DriverDocuments([
        _document('Contrôle technique', DriverDocumentStatus.missing),
      ]);

      // Act
      final blocksDriving = documents.blocksDriving;

      // Assert
      expect(blocksDriving, isTrue);
    });

    test('asks for the blocking document before the one expiring soon', () {
      // Arrange
      final documents = DriverDocuments([
        _document('Carte professionnelle', DriverDocumentStatus.expiringSoon),
        _document('Permis', DriverDocumentStatus.expired),
      ]);

      // Act
      final nextToProvide = documents.nextToProvide;

      // Assert
      expect(nextToProvide?.name, 'Permis');
    });

    test('a document waiting for the admin is not asked again', () {
      // Arrange
      final documents = DriverDocuments([
        _document('Permis', DriverDocumentStatus.expired, inReview: true),
        _document('Carte professionnelle', DriverDocumentStatus.expiringSoon),
      ]);

      // Act
      final nextToProvide = documents.nextToProvide;

      // Assert
      expect(nextToProvide?.name, 'Carte professionnelle');
    });

    test('every document to renew already sent: nothing to send', () {
      // Arrange
      final documents = DriverDocuments([
        _document(
          'Carte d’identité',
          DriverDocumentStatus.expiringSoon,
          inReview: true,
        ),
        _document('Permis', DriverDocumentStatus.validated),
      ]);

      // Act
      final hasDocumentToSend = documents.hasDocumentToSend;

      // Assert
      expect(hasDocumentToSend, isFalse);
    });

    test('one sent, another still to renew: something to send', () {
      // Arrange
      final documents = DriverDocuments([
        _document(
          'Carte d’identité',
          DriverDocumentStatus.expiringSoon,
          inReview: true,
        ),
        _document('Permis', DriverDocumentStatus.expiringSoon),
      ]);

      // Act
      final hasDocumentToSend = documents.hasDocumentToSend;

      // Assert
      expect(hasDocumentToSend, isTrue);
    });

    test('the bookings stop at the soonest end of a document', () {
      // Arrange
      final documents = DriverDocuments([
        _document(
          'Permis',
          DriverDocumentStatus.validated,
          expiresAt: DateTime(2031, 5),
        ),
        _document(
          'Carte professionnelle',
          DriverDocumentStatus.expiringSoon,
          expiresAt: DateTime(2027, 3, 11),
        ),
        _document(
          'Contrôle technique',
          DriverDocumentStatus.toProvide,
          requiredFrom: DateTime(2027, 4),
        ),
      ]);

      // Act
      final soonest = documents.soonestEnd;

      // Assert
      expect(soonest?.name, 'Carte professionnelle');
    });

    test('sent but not validated yet: still ends the bookings', () {
      // Arrange
      final documents = DriverDocuments([
        _document(
          'Carte professionnelle',
          DriverDocumentStatus.expiringSoon,
          expiresAt: DateTime(2027, 3, 11),
          inReview: true,
        ),
      ]);

      // Act
      final soonest = documents.soonestEnd;

      // Assert
      expect(soonest?.name, 'Carte professionnelle');
    });

    test('counts the validated documents', () {
      // Arrange
      final documents = DriverDocuments([
        _document('Carte professionnelle', DriverDocumentStatus.validated),
        _document('Permis', DriverDocumentStatus.expiringSoon),
      ]);

      // Act
      final validatedCount = documents.validatedCount;

      // Assert
      expect(validatedCount, 1);
    });
  });
}

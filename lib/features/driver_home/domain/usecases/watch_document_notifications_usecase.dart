import 'package:mobile/core/domain/repositories/push_registration_repository.dart';

// A notification about the documents, received on screen or tapped: a
// reminder, an expiry, a document validated. The documents are read again.
// Spec taxi-vroom-api/docs/specs/documents-du-chauffeur.md, step 6 bis.
class WatchDocumentNotificationsUseCase {
  const WatchDocumentNotificationsUseCase(this._repository);

  static const _documentsType = 'documents';

  final PushRegistrationRepository _repository;

  Stream<void> call() => _repository.watchNotificationTypes().where(
    (type) => type == _documentsType,
  );
}

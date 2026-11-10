import 'package:mobile/core/domain/repositories/push_registration_repository.dart';

// The driver tapped "Dossier validé": the home opens at once, without
// reading the registration again. Spec
// taxi-vroom-api/docs/specs/validation-du-dossier.md, step 3 ter.
class WatchValidationNotificationOpenedUseCase {
  const WatchValidationNotificationOpenedUseCase(this._repository);

  static const _validatedType = 'registration-validated';

  final PushRegistrationRepository _repository;

  Stream<void> call() =>
      _repository.watchOpenedTypes().where((type) => type == _validatedType);
}

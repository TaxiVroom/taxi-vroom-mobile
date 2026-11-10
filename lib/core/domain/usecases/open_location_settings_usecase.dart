import 'package:mobile/core/domain/repositories/location_repository.dart';

// "Ouvrir les réglages", once the location was refused for good: the
// person asked for it, so the settings open.
class OpenLocationSettingsUseCase {
  const OpenLocationSettingsUseCase(this._repository);

  final LocationRepository _repository;

  Future<void> call() => _repository.openSettings();
}

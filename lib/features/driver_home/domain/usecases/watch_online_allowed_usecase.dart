import 'package:mobile/features/driver_home/domain/repositories/driver_presence_repository.dart';

// While online: the server took the driver offline because a document
// expired or is missing, once no ride is in progress. Spec
// taxi-vroom-api/docs/specs/documents-du-chauffeur.md, point 8.
class WatchOnlineAllowedUseCase {
  const WatchOnlineAllowedUseCase(this._repository);

  final DriverPresenceRepository _repository;

  Stream<void> call() => _repository.watchOnlineAllowed().distinct().where(
    (isAllowed) => !isAllowed,
  );
}

import 'package:mobile/core/domain/repositories/connection_repository.dart';

// Whether the device is connected, to warn the user when it is not: the
// driver is no longer seen, the passenger no longer sees the taxis move.
class WatchConnectionUseCase {
  const WatchConnectionUseCase(this._connectionRepository);

  final ConnectionRepository _connectionRepository;

  Stream<bool> call() => _connectionRepository.watchConnection();
}

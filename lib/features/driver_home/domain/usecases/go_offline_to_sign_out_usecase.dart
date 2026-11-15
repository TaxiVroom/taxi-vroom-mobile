import 'dart:async';

import 'package:mobile/core/domain/repositories/connection_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_presence_repository.dart';

// "Se déconnecter" while online: offline first, for good. Signed out, the app
// may no longer remove the driver's entry, which would stay for the
// passengers. Without network, refused: the driver stays connected and online
// (validated by the user, 2026-11-15). Spec
// taxi-vroom-api/docs/specs/presence-du-chauffeur-au-demarrage.md, situation 5.
class GoOfflineToSignOutUseCase {
  const GoOfflineToSignOutUseCase({
    required ConnectionRepository connectionRepository,
    required DriverPresenceRepository driverPresenceRepository,
  }) : _connectionRepository = connectionRepository,
       _driverPresenceRepository = driverPresenceRepository;

  final ConnectionRepository _connectionRepository;
  final DriverPresenceRepository _driverPresenceRepository;

  // Firebase tells the connection state at once when listened to.
  static const _connectionLimit = Duration(seconds: 3);

  static const noNetwork = NetworkFailure(
    'Connexion requise pour vous déconnecter en étant en ligne.',
  );

  Future<Result<void>> call() async {
    if (!await _isConnected()) return const Result.error(noNetwork);
    return switch (await _driverPresenceRepository.goOfflineConfirmed()) {
      Ok() => const Result.ok(null),
      Error() => const Result.error(noNetwork),
    };
  }

  Future<bool> _isConnected() async {
    try {
      return await _connectionRepository.watchConnection().first.timeout(
        _connectionLimit,
      );
    } on TimeoutException {
      return false;
    }
  }
}

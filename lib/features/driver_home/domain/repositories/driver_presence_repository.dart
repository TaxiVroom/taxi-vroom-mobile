import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';

// The driver's live presence, seen by the passengers and the backend: where
// they are while online, gone as soon as they go offline or lose the
// connection.
abstract class DriverPresenceRepository {
  Future<Result<void>> goOnline(Coordinates position);

  Future<Result<void>> updatePosition(Coordinates position);

  Future<Result<void>> goOffline();

  // Offline, and only once the server confirmed the entry is gone: what is
  // needed before signing out, after which the app may no longer remove it.
  Future<Result<void>> goOfflineConfirmed();

  // Whether the driver's entry is still there, e.g. left by an app restarted
  // while online.
  Future<Result<bool>> hasPresence();

  // False once the server takes the driver offline for a document.
  Stream<bool> watchOnlineAllowed();
}

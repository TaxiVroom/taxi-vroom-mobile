import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';

// The driver's live presence, seen by the passengers and the backend: where
// they are while online, gone as soon as they go offline or lose the
// connection.
abstract class DriverPresenceRepository {
  Future<Result<void>> goOnline(Coordinates position);

  Future<Result<void>> updatePosition(Coordinates position);

  Future<Result<void>> goOffline();

  // Whether the device reaches the server: while it does not, the driver is
  // no longer seen, and comes back by themself once reconnected.
  Stream<bool> watchConnection();
}

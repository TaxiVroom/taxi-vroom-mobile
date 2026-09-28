// Whether the device reaches the realtime server. Offline, what the app
// shows is the last data received, and the others no longer see its changes.
abstract class ConnectionRepository {
  Stream<bool> watchConnection();
}

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geo_hash/flutter_geo_hash.dart';

abstract class DriverPresenceRemoteDataSource {
  Future<void> goOnline({required double latitude, required double longitude});

  Future<void> updatePosition({
    required double latitude,
    required double longitude,
  });

  Future<void> goOffline();

  // Throws TimeoutException when the server did not confirm in time.
  Future<void> goOfflineConfirmed();

  // Throws TimeoutException when neither the server nor the cache answers in
  // time.
  Future<bool> hasPresence();

  // onlineAllowed/<uid>, written by the server only: false once it takes
  // the driver offline for a document. Spec
  // taxi-vroom-api/docs/specs/documents-du-chauffeur.md, point 8.
  Stream<bool> watchOnlineAllowed();
}

// Firebase Realtime Database, one entry per online driver at
// drivers/<uid>, overwritten at each position and removed on disconnect.
// Docs: https://firebase.google.com/docs/database/flutter/read-and-write
// and https://firebase.google.com/docs/database/flutter/offline-capabilities
class DriverPresenceRemoteDataSourceImpl
    implements DriverPresenceRemoteDataSource {
  DriverPresenceRemoteDataSourceImpl(this._database, this._firebaseAuth);

  final FirebaseDatabase _database;
  final FirebaseAuth _firebaseAuth;
  final _geoHash = GeoHashUtils();

  // Re-arms the presence after each reconnection, as in the Firebase sample.
  StreamSubscription<DatabaseEvent>? _connection;
  ({double latitude, double longitude})? _lastPosition;

  DatabaseReference get _driverRef {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseException(
        plugin: 'firebase_database',
        code: 'unauthenticated',
        message: 'Connectez-vous pour passer en ligne.',
      );
    }
    return _database.ref('drivers/$uid');
  }

  @override
  Future<void> goOnline({
    required double latitude,
    required double longitude,
  }) async {
    final driverRef = _driverRef;
    _lastPosition = (latitude: latitude, longitude: longitude);
    // The server removes the entry itself if this device disconnects.
    await driverRef.onDisconnect().remove();
    await driverRef.set(_entry(latitude, longitude));

    // After a reconnection, the disconnect operation has already run: arm it
    // again and write the entry back.
    await _connection?.cancel();
    _connection = _database.ref('.info/connected').onValue.listen((
      event,
    ) async {
      final connected = event.snapshot.value as bool? ?? false;
      final position = _lastPosition;
      if (!connected || position == null) return;
      await driverRef.onDisconnect().remove();
      await driverRef.set(_entry(position.latitude, position.longitude));
    });
  }

  @override
  Future<void> updatePosition({
    required double latitude,
    required double longitude,
  }) async {
    _lastPosition = (latitude: latitude, longitude: longitude);
    await _driverRef.update({
      'latitude': latitude,
      'longitude': longitude,
      'geohash': _geohash(latitude, longitude),
      'updatedAt': ServerValue.timestamp,
    });
  }

  @override
  Future<void> goOffline() async {
    final driverRef = _driverRef;
    _lastPosition = null;
    await _connection?.cancel();
    _connection = null;
    // Not awaited: offline, Firebase queues these writes until the connection
    // comes back. The driver is gone for passengers either way: removed once
    // reconnected, or by the onDisconnect armed when going online.
    driverRef.onDisconnect().cancel().ignore();
    driverRef.remove().ignore();
  }

  // The doc gives no time limit: "If for some reason get() can't return the
  // server value, the client will probe the local storage cache and return
  // an error if the value is still not found."
  // https://firebase.google.com/docs/database/flutter/read-and-write
  static const _answerLimit = Duration(seconds: 10);

  @override
  Future<void> goOfflineConfirmed() async {
    final driverRef = _driverRef;
    _lastPosition = null;
    await _connection?.cancel();
    _connection = null;
    // Awaited, unlike goOffline: the futures end once the server applied
    // them.
    await driverRef.onDisconnect().cancel().timeout(_answerLimit);
    await driverRef.remove().timeout(_answerLimit);
  }

  @override
  Future<bool> hasPresence() async =>
      (await _driverRef.get().timeout(_answerLimit)).exists;

  @override
  Stream<bool> watchOnlineAllowed() => _database
      .ref('onlineAllowed/${_firebaseAuth.currentUser?.uid}')
      .onValue
      .map((event) => event.snapshot.value == true);

  Map<String, Object> _entry(double latitude, double longitude) => {
    'latitude': latitude,
    'longitude': longitude,
    'geohash': _geohash(latitude, longitude),
    'available': true,
    'updatedAt': ServerValue.timestamp,
  };

  String _geohash(double latitude, double longitude) =>
      _geoHash.geoHashForLocation(GeoHashPoint(latitude, longitude));
}

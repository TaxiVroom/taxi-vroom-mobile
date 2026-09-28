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

  // Whether this device is connected to the database, again at each change.
  Stream<bool> watchConnection();
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

  // "Detecting Connection State" in the offline capabilities docs.
  @override
  Stream<bool> watchConnection() => _database
      .ref('.info/connected')
      .onValue
      .map((event) => event.snapshot.value as bool? ?? false);

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

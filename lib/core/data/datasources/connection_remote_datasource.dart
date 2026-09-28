import 'package:firebase_database/firebase_database.dart';

abstract class ConnectionRemoteDataSource {
  // Whether this device is connected to the database, again at each change.
  Stream<bool> watchConnection();
}

// "Detecting Connection State" in
// https://firebase.google.com/docs/database/flutter/offline-capabilities
class ConnectionRemoteDataSourceImpl implements ConnectionRemoteDataSource {
  const ConnectionRemoteDataSourceImpl(this._database);

  final FirebaseDatabase _database;

  @override
  Stream<bool> watchConnection() => _database
      .ref('.info/connected')
      .onValue
      .map((event) => event.snapshot.value as bool? ?? false);
}

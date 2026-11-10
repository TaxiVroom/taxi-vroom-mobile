import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_presence_remote_datasource.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_presence_repository.dart';

class DriverPresenceRepositoryImpl implements DriverPresenceRepository {
  const DriverPresenceRepositoryImpl(this._dataSource);

  final DriverPresenceRemoteDataSource _dataSource;

  @override
  Future<Result<void>> goOnline(Coordinates position) => _run(
    () => _dataSource.goOnline(
      latitude: position.latitude,
      longitude: position.longitude,
    ),
  );

  @override
  Future<Result<void>> updatePosition(Coordinates position) => _run(
    () => _dataSource.updatePosition(
      latitude: position.latitude,
      longitude: position.longitude,
    ),
  );

  @override
  Future<Result<void>> goOffline() => _run(_dataSource.goOffline);

  // A read refused or failed counts as "still allowed": the dispatch keeps
  // a blocked driver out anyway.
  @override
  Stream<bool> watchOnlineAllowed() =>
      _dataSource.watchOnlineAllowed().transform(
        StreamTransformer.fromHandlers(
          handleError: (_, _, sink) => sink.add(true),
        ),
      );

  Future<Result<void>> _run(Future<void> Function() operation) async {
    try {
      await operation();
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        ServerFailure(e.message ?? 'Connexion au service impossible.'),
      );
    }
  }
}

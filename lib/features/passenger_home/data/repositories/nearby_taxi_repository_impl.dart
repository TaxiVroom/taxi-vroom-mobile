import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/data/datasources/nearby_taxi_remote_datasource.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';
import 'package:mobile/features/passenger_home/domain/repositories/nearby_taxi_repository.dart';

class NearbyTaxiRepositoryImpl implements NearbyTaxiRepository {
  const NearbyTaxiRepositoryImpl(this._dataSource);

  final NearbyTaxiRemoteDataSource _dataSource;

  @override
  Stream<Result<List<NearbyTaxi>>> watchNearbyTaxis({
    required Coordinates around,
    required double radiusMeters,
  }) => _dataSource
      .watchNearbyTaxis(
        latitude: around.latitude,
        longitude: around.longitude,
        radiusMeters: radiusMeters,
      )
      .transform(
        StreamTransformer.fromHandlers(
          handleData: (models, sink) => sink.add(
            Result.ok([for (final model in models) model.toDomain()]),
          ),
          handleError: (error, stackTrace, sink) => switch (error) {
            FirebaseException(:final message) => sink.add(
              Result.error(
                ServerFailure(message ?? 'Connexion au service impossible.'),
              ),
            ),
            _ => sink.addError(error, stackTrace),
          },
        ),
      );
}

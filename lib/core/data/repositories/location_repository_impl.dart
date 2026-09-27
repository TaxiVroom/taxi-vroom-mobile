import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:mobile/core/data/datasources/device_location_datasource.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._dataSource);

  final DeviceLocationDataSource _dataSource;

  static const _serviceDisabled = LocationFailure(
    'Activez la localisation de votre téléphone.',
  );
  static const _permissionDenied = LocationFailure(
    'Autorisez l’accès à votre position.',
  );

  @override
  Future<Result<Coordinates>> getCurrentPosition() async {
    try {
      return Result.ok(_toCoordinates(await _dataSource.getCurrentPosition()));
    } on LocationServiceDisabledException {
      return const Result.error(_serviceDisabled);
    } on PermissionDeniedException {
      return const Result.error(_permissionDenied);
    }
  }

  // Not an async* with await for: its cancel would wait for the next
  // position, which never comes while the device does not move.
  @override
  Stream<Result<Coordinates>> watchPosition() =>
      _dataSource.watchPosition().transform(
        StreamTransformer.fromHandlers(
          handleData: (position, sink) =>
              sink.add(Result.ok(_toCoordinates(position))),
          handleError: (error, stackTrace, sink) => switch (error) {
            LocationServiceDisabledException() => sink.add(
              const Result.error(_serviceDisabled),
            ),
            PermissionDeniedException() => sink.add(
              const Result.error(_permissionDenied),
            ),
            _ => sink.addError(error, stackTrace),
          },
        ),
      );

  Coordinates _toCoordinates(Position position) =>
      Coordinates(latitude: position.latitude, longitude: position.longitude);
}

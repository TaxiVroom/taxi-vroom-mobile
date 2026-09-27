import 'package:geolocator/geolocator.dart';
import 'package:mobile/core/data/datasources/device_location_datasource.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._dataSource);

  final DeviceLocationDataSource _dataSource;

  @override
  Future<Result<Coordinates>> getCurrentPosition() async {
    try {
      final position = await _dataSource.getCurrentPosition();
      return Result.ok(
        Coordinates(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } on LocationServiceDisabledException {
      return const Result.error(
        LocationFailure('Activez la localisation de votre téléphone.'),
      );
    } on PermissionDeniedException {
      return const Result.error(
        LocationFailure('Autorisez l’accès à votre position.'),
      );
    }
  }
}

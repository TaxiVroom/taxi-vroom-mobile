import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';

abstract class LocationRepository {
  Future<Result<Coordinates>> getCurrentPosition();

  // The position each time the device moves, while listened to.
  Stream<Result<Coordinates>> watchPosition();
}

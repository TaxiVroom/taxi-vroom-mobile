import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';

abstract class LocationRepository {
  Future<Result<Coordinates>> getCurrentPosition();
}

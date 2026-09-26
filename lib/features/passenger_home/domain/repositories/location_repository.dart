import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';

abstract class LocationRepository {
  Future<Result<Coordinates>> getCurrentPosition();
}

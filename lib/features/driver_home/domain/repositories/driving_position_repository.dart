import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';

abstract class DrivingPositionRepository {
  // The driver's position while they drive [along] a route. The device GPS
  // ignores [along]; a simulated drive, for tests without driving, follows
  // it.
  Stream<Result<Coordinates>> watchPosition({
    required List<Coordinates> along,
  });
}

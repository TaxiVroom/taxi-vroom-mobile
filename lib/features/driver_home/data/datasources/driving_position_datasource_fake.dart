import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/driver_home/data/datasources/driving_position_datasource.dart';

/// Implémentation de développement : simule un trajet en voiture le long de
/// l'itinéraire reçu, en accéléré, pour voir le guidage avancer sans rouler.
class DrivingPositionDataSourceFake implements DrivingPositionDataSource {
  static const _tick = Duration(seconds: 1);

  // About 3 times the speed of a car in town.
  static const _metersPerTick = 40.0;

  @override
  Stream<Coordinates> watchPosition({
    required List<Coordinates> along,
  }) async* {
    if (along.isEmpty) return;
    var position = along.first;
    var next = 1;
    yield position;
    while (next < along.length) {
      await Future<void>.delayed(_tick);
      // Drives _metersPerTick along the route, across its points if needed.
      var toDrive = _metersPerTick;
      while (next < along.length &&
          position.distanceTo(along[next]) <= toDrive) {
        toDrive -= position.distanceTo(along[next]);
        position = along[next];
        next++;
      }
      if (next < along.length) {
        position = _moveTowards(position, along[next], toDrive);
      }
      yield position;
    }
  }

  Coordinates _moveTowards(Coordinates from, Coordinates to, double meters) {
    final ratio = meters / from.distanceTo(to);
    return Coordinates(
      latitude: from.latitude + (to.latitude - from.latitude) * ratio,
      longitude: from.longitude + (to.longitude - from.longitude) * ratio,
    );
  }
}

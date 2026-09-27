import 'package:mobile/core/domain/entities/coordinates.dart';

// Only the simulated drive exists for now; the device GPS will come later.
abstract class DrivingPositionDataSource {
  Stream<Coordinates> watchPosition({required List<Coordinates> along});
}

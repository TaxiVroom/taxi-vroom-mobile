import 'package:mobile/core/domain/entities/coordinates.dart';

// A simulated drive, to test the guidance without driving: the device GPS
// goes through DeviceDrivingPositionRepository instead.
abstract class DrivingPositionDataSource {
  Stream<Coordinates> watchPosition({required List<Coordinates> along});
}

import 'package:geolocator/geolocator.dart';

abstract class DeviceLocationDataSource {
  Future<Position> getCurrentPosition();
}

class DeviceLocationDataSourceImpl implements DeviceLocationDataSource {
  const DeviceLocationDataSourceImpl();

  // Asks for the location permission if needed, then reads the GPS position.
  // Throws LocationServiceDisabledException or PermissionDeniedException.
  @override
  Future<Position> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const PermissionDeniedException('Location permission denied');
    }

    return Geolocator.getCurrentPosition();
  }
}

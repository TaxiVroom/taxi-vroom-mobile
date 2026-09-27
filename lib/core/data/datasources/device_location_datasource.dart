import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:geolocator/geolocator.dart';

abstract class DeviceLocationDataSource {
  Future<Position> getCurrentPosition();

  // The position each time the device moves, while listened to.
  Stream<Position> watchPosition();
}

class DeviceLocationDataSourceImpl implements DeviceLocationDataSource {
  const DeviceLocationDataSourceImpl();

  // Android computes the position less often, which saves battery.
  static const _androidInterval = Duration(seconds: 3);

  // Asks for the location permission if needed, then reads the GPS position.
  // Throws LocationServiceDisabledException or PermissionDeniedException.
  @override
  Future<Position> getCurrentPosition() async {
    await _ensurePermission();
    return Geolocator.getCurrentPosition();
  }

  @override
  Stream<Position> watchPosition() async* {
    await _ensurePermission();
    yield* Geolocator.getPositionStream(locationSettings: _locationSettings);
  }

  LocationSettings get _locationSettings => switch (defaultTargetPlatform) {
    TargetPlatform.android => AndroidSettings(
      intervalDuration: _androidInterval,
    ),
    _ => const LocationSettings(),
  };

  Future<void> _ensurePermission() async {
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
  }
}

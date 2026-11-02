import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:geolocator/geolocator.dart';

abstract class DeviceLocationDataSource {
  Future<Position> getCurrentPosition();

  // The position each time the device moves, while listened to. With
  // [inBackground], it goes on when the app is no longer on screen.
  Stream<Position> watchPosition({bool inBackground = false});
}

class DeviceLocationDataSourceImpl implements DeviceLocationDataSource {
  const DeviceLocationDataSourceImpl();

  // Android computes the position less often, which saves battery.
  static const _androidInterval = Duration(seconds: 3);

  // Android only lets an app keep the position with a visible notification.
  static const _inBackgroundNotification = ForegroundNotificationConfig(
    notificationTitle: 'Vous êtes en ligne',
    notificationText: 'Votre position sert à vous proposer des courses.',
    notificationChannelName: 'En ligne',
    enableWakeLock: true,
    setOngoing: true,
  );

  // Asks for the location permission if needed, then reads the GPS position.
  // Throws LocationServiceDisabledException or PermissionDeniedException.
  @override
  Future<Position> getCurrentPosition() async {
    await _ensurePermission();
    return Geolocator.getCurrentPosition();
  }

  @override
  Stream<Position> watchPosition({bool inBackground = false}) async* {
    await _ensurePermission();
    yield* Geolocator.getPositionStream(
      locationSettings: _locationSettings(inBackground: inBackground),
    );
  }

  // Docs: https://github.com/baseflow/flutter-geolocator/blob/main/geolocator/README.md
  LocationSettings _locationSettings({required bool inBackground}) =>
      switch (defaultTargetPlatform) {
        TargetPlatform.android => AndroidSettings(
          intervalDuration: _androidInterval,
          foregroundNotificationConfig: inBackground
              ? _inBackgroundNotification
              : null,
        ),
        TargetPlatform.iOS => AppleSettings(
          activityType: ActivityType.automotiveNavigation,
          allowBackgroundLocationUpdates: inBackground,
          showBackgroundLocationIndicator: inBackground,
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

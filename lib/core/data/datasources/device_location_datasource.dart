import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:geolocator/geolocator.dart';

// Refused for good: Android or iOS no longer shows its window, only the
// settings can allow it now.
class LocationPermanentlyDeniedException implements Exception {
  const LocationPermanentlyDeniedException();
}

abstract class DeviceLocationDataSource {
  // Throws a TimeoutException when no position comes within the time limit.
  Future<Position> getCurrentPosition();

  // The app's settings, where a permission refused for good can be allowed.
  Future<void> openAppSettings();

  // The position each time the device moves, while listened to. With
  // [inBackground], it goes on when the app is no longer on screen.
  Stream<Position> watchPosition({bool inBackground = false});
}

class DeviceLocationDataSourceImpl implements DeviceLocationDataSource {
  const DeviceLocationDataSourceImpl();

  // Long enough for a first GPS fix outdoors; never an endless wait.
  // https://github.com/baseflow/flutter-geolocator/blob/main/geolocator/README.md
  static const _positionTimeLimit = Duration(seconds: 15);

  // One permission request at a time for the whole app: two screens asking
  // together made Android refuse the second one ("Can request only one set
  // of permissions at a time"), which then never got an answer.
  static Future<void>? _pendingPermission;

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
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(timeLimit: _positionTimeLimit),
    );
  }

  @override
  Future<void> openAppSettings() => Geolocator.openAppSettings();

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
    final pending = _pendingPermission ??= _askPermission().whenComplete(
      () => _pendingPermission = null,
    );
    await pending;
  }

  Future<void> _askPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermanentlyDeniedException();
    }
    if (permission == LocationPermission.denied) {
      throw const PermissionDeniedException('Location permission denied');
    }
  }
}

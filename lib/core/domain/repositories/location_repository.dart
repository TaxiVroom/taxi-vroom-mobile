import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';

abstract class LocationRepository {
  Future<Result<Coordinates>> getCurrentPosition();

  // The position each time the device moves, while listened to. With
  // [inBackground], it goes on when the app is no longer on screen.
  Stream<Result<Coordinates>> watchPosition({bool inBackground = false});

  // The app's settings, after a refusal for good.
  Future<void> openSettings();
}

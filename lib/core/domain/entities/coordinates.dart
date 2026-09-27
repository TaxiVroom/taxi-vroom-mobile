import 'dart:math' as math;

import 'package:equatable/equatable.dart';

class Coordinates extends Equatable {
  const Coordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  static const _earthRadiusMeters = 6371000.0;

  // Straight-line distance on the Earth's surface (haversine formula).
  double distanceTo(Coordinates other) {
    final dLatitude = _radians(other.latitude - latitude);
    final dLongitude = _radians(other.longitude - longitude);
    final a =
        math.pow(math.sin(dLatitude / 2), 2) +
        math.cos(_radians(latitude)) *
            math.cos(_radians(other.latitude)) *
            math.pow(math.sin(dLongitude / 2), 2);
    return 2 * _earthRadiusMeters * math.asin(math.sqrt(a));
  }

  // Compass direction to go to [other], in degrees: 0 north, 90 east.
  double bearingTo(Coordinates other) {
    final fromLatitude = _radians(latitude);
    final toLatitude = _radians(other.latitude);
    final dLongitude = _radians(other.longitude - longitude);
    final y = math.sin(dLongitude) * math.cos(toLatitude);
    final x =
        math.cos(fromLatitude) * math.sin(toLatitude) -
        math.sin(fromLatitude) * math.cos(toLatitude) * math.cos(dLongitude);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  static double _radians(double degrees) => degrees * math.pi / 180;

  @override
  List<Object?> get props => [latitude, longitude];
}

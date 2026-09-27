import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';

// A place where passengers are currently asking for taxis.
class DemandZone extends Equatable {
  const DemandZone({
    required this.center,
    required this.isHigh,
    required this.driveMinutes,
    this.name,
  });

  final Coordinates center;

  // High demand: worth driving there.
  final bool isHigh;

  // Driving time from the driver's position.
  final int driveMinutes;

  // Shown on the map for well-known places, e.g. "Gare".
  final String? name;

  @override
  List<Object?> get props => [center, isHigh, driveMinutes, name];
}

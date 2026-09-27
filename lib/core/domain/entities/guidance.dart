import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/navigation_step.dart';

// What the navigation banner shows at a given position.
class Guidance extends Equatable {
  const Guidance({
    required this.position,
    required this.heading,
    required this.maneuverLocation,
    required this.nextManeuver,
    required this.roadName,
    required this.metersToManeuver,
    required this.metersLeft,
    required this.minutesLeft,
    required this.remainingPath,
  });

  // Where the driver is.
  final Coordinates position;

  // Compass direction of the road ahead, in degrees: the map turns with it.
  final double heading;

  // Where the next maneuver happens: the map frames it with the driver.
  final Coordinates maneuverLocation;

  // [Maneuver.arrive] on the last stretch.
  final Maneuver nextManeuver;

  // The road taken after the maneuver.
  final String roadName;

  final int metersToManeuver;

  // Distance and time left to the end of the route.
  final int metersLeft;
  final int minutesLeft;

  // The road still to drive, from the current position.
  final List<Coordinates> remainingPath;

  @override
  List<Object?> get props => [
    position,
    heading,
    maneuverLocation,
    nextManeuver,
    roadName,
    metersToManeuver,
    metersLeft,
    minutesLeft,
    remainingPath,
  ];
}

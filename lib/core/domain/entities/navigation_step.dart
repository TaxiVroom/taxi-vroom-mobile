import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';

// What the driver does at a maneuver point.
enum Maneuver {
  depart,
  straight,
  slightRight,
  right,
  sharpRight,
  slightLeft,
  left,
  sharpLeft,
  uturn,
  roundabout,
  arrive,
}

// One step of a turn-by-turn route: a maneuver, then a road to follow.
class NavigationStep extends Equatable {
  const NavigationStep({
    required this.maneuver,
    required this.location,
    required this.roadName,
  });

  final Maneuver maneuver;

  // Where the maneuver happens.
  final Coordinates location;

  // The road taken after the maneuver, empty when it has no name.
  final String roadName;

  @override
  List<Object?> get props => [maneuver, location, roadName];
}

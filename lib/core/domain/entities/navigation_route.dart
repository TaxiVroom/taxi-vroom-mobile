import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/guidance.dart';
import 'package:mobile/core/domain/entities/navigation_step.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';

// A route with its turn-by-turn steps, to guide the driver.
class NavigationRoute extends Equatable {
  const NavigationRoute({required this.route, required this.steps});

  final RideRoute route;

  // In driving order, the first one being the departure.
  final List<NavigationStep> steps;

  // Guidance from [position]: the next maneuver ahead, how far it is, and
  // the time left, in proportion to the distance left.
  Guidance guidanceFrom(Coordinates position) {
    final path = route.path;
    final distances = _distancesAlongPath();
    final current = _closestIndex(position);
    final nextStep =
        steps.skip(1).where((step) {
          return _closestIndex(step.location) > current;
        }).firstOrNull ??
        steps.last;

    final maneuverIndex = _closestIndex(nextStep.location);
    final total = distances.last;
    final remaining = total - distances[current];
    final minutesLeft = total == 0
        ? 0
        : (route.durationMinutes * remaining / total).ceil();
    return Guidance(
      position: position,
      heading: _headingFrom(position, current),
      maneuverLocation: nextStep.location,
      nextManeuver: nextStep.maneuver,
      roadName: nextStep.roadName,
      metersToManeuver: (distances[maneuverIndex] - distances[current])
          .clamp(0, total)
          .round(),
      metersLeft: remaining.round(),
      minutesLeft: minutesLeft,
      remainingPath: [position, ...path.skip(current + 1)],
    );
  }

  // Towards the next point of the road; on the last point, the direction of
  // the last stretch.
  double _headingFrom(Coordinates position, int current) {
    final path = route.path;
    if (path.length < 2) return 0;
    if (current + 1 < path.length) {
      return position.bearingTo(path[current + 1]);
    }
    return path[path.length - 2].bearingTo(path.last);
  }

  // Distance driven from the start to each point of the path.
  List<double> _distancesAlongPath() {
    final path = route.path;
    final distances = [0.0];
    for (var i = 1; i < path.length; i++) {
      distances.add(distances.last + path[i - 1].distanceTo(path[i]));
    }
    return distances;
  }

  int _closestIndex(Coordinates position) {
    final path = route.path;
    var closest = 0;
    for (var i = 1; i < path.length; i++) {
      if (path[i].distanceTo(position) < path[closest].distanceTo(position)) {
        closest = i;
      }
    }
    return closest;
  }

  @override
  List<Object?> get props => [route, steps];
}

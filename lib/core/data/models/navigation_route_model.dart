import 'package:mobile/core/data/models/ride_route_model.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/navigation_route.dart';
import 'package:mobile/core/domain/entities/navigation_step.dart';

// One item of `routes` in the Mapbox Directions API response, requested with
// geometries=geojson and steps=true.
class NavigationRouteModel {
  const NavigationRouteModel({required this.route, required this.steps});

  factory NavigationRouteModel.fromJson(Map<String, dynamic> json) {
    final legs = json['legs'] as List<dynamic>;
    return NavigationRouteModel(
      route: RideRouteModel.fromJson(json),
      steps: [
        for (final leg in legs)
          for (final step in (leg as Map<String, dynamic>)['steps'] as List)
            NavigationStepModel.fromJson(step as Map<String, dynamic>),
      ],
    );
  }

  final RideRouteModel route;
  final List<NavigationStepModel> steps;

  NavigationRoute toDomain() => NavigationRoute(
    route: route.toDomain(),
    steps: steps.map((step) => step.toDomain()).toList(),
  );
}

// A route step: its maneuver (type, modifier, location) and road name.
class NavigationStepModel {
  const NavigationStepModel({
    required this.type,
    required this.modifier,
    required this.latitude,
    required this.longitude,
    required this.roadName,
  });

  factory NavigationStepModel.fromJson(Map<String, dynamic> json) {
    final maneuver = json['maneuver'] as Map<String, dynamic>;
    // GeoJSON order: [longitude, latitude].
    final location = maneuver['location'] as List<dynamic>;
    return NavigationStepModel(
      type: maneuver['type'] as String,
      modifier: maneuver['modifier'] as String?,
      latitude: (location[1] as num).toDouble(),
      longitude: (location[0] as num).toDouble(),
      roadName: json['name'] as String? ?? '',
    );
  }

  final String type;
  final String? modifier;
  final double latitude;
  final double longitude;
  final String roadName;

  NavigationStep toDomain() => NavigationStep(
    maneuver: _maneuver,
    location: Coordinates(latitude: latitude, longitude: longitude),
    roadName: roadName,
  );

  Maneuver get _maneuver => switch ((type, modifier)) {
    ('depart', _) => Maneuver.depart,
    ('arrive', _) => Maneuver.arrive,
    ('roundabout' || 'rotary' || 'roundabout turn', _) => Maneuver.roundabout,
    (_, 'uturn') => Maneuver.uturn,
    (_, 'sharp right') => Maneuver.sharpRight,
    (_, 'right') => Maneuver.right,
    (_, 'slight right') => Maneuver.slightRight,
    (_, 'sharp left') => Maneuver.sharpLeft,
    (_, 'left') => Maneuver.left,
    (_, 'slight left') => Maneuver.slightLeft,
    _ => Maneuver.straight,
  };
}

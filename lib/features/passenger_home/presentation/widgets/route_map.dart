import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show CameraViewportState, LocationComponentSettings, MapWidget, MapboxMap;
import 'package:mobile/features/passenger_home/domain/entities/ride_route.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/coordinates_mapbox.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/destination_marker.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/map_route.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Full-screen map framed on the route, drawn from the passenger to the
/// destination.
class RouteMap extends StatelessWidget {
  const RouteMap({
    required this.route,
    required this.bottomPadding,
    super.key,
  });

  final RideRoute route;

  // Keeps the route visible above the bottom panel.
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      // Starts at street level on the destination, then frames the whole
      // route in _onMapCreated (otherwise Mapbox opens on the globe).
      viewport: route.path.isEmpty
          ? null
          : CameraViewportState(center: route.path.last.toPoint(), zoom: 13),
      onMapCreated: _onMapCreated,
    );
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    await map.location.updateSettings(
      LocationComponentSettings(enabled: true),
    );

    final routeLine = await map.annotations.createPolylineAnnotationManager();
    await routeLine.create(routeLineOptions(route.path));

    if (route.path.isEmpty) return;
    await showDestinationMarker(map, route.path.last);
    await map.setCamera(
      await cameraOnPath(map, route.path, bottomPadding: bottomPadding),
    );
  }
}

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show
        CameraViewportState,
        CircleAnnotationManager,
        CircleAnnotationOptions,
        LocationComponentSettings,
        MapAnimationOptions,
        MapWidget,
        MapboxMap,
        PolylineAnnotationManager;
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/coordinates_mapbox.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/destination_marker.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/map_route.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Map of an ordered ride: the taxi coming to the passenger, then driving to
/// the destination along the remaining route, followed by the camera.
class RideMap extends StatefulWidget {
  const RideMap({
    required this.origin,
    required this.bottomPadding,
    this.driverPosition,
    this.destination,
    this.remainingRoute,
    super.key,
  });

  final Coordinates origin;

  // Keeps the route visible above the bottom panel.
  final double bottomPadding;

  // Null while no driver is assigned yet.
  final Coordinates? driverPosition;

  // Shown once the ride has started.
  final Coordinates? destination;

  // Road left from the taxi to the destination, once the ride has started.
  final List<Coordinates>? remainingRoute;

  @override
  State<RideMap> createState() => _RideMapState();
}

class _RideMapState extends State<RideMap> {
  static const _cameraAnimation = Duration(milliseconds: 800);

  MapboxMap? _map;
  PolylineAnnotationManager? _routeLine;
  CircleAnnotationManager? _driverMarker;

  @override
  void didUpdateWidget(RideMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingRoute != widget.remainingRoute) _showRoute();
    if (oldWidget.driverPosition != widget.driverPosition) _showDriver();
    if (oldWidget.destination == null) _showDestination();
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      viewport: CameraViewportState(center: widget.origin.toPoint(), zoom: 14),
      onMapCreated: _onMapCreated,
    );
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await map.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
    // Created first so the route line stays under the taxi marker.
    _routeLine = await map.annotations.createPolylineAnnotationManager();
    _driverMarker = await map.annotations.createCircleAnnotationManager();
    await _showRoute();
    await _showDriver();
    await _showDestination();
  }

  Future<void> _showRoute() async {
    final map = _map;
    final routeLine = _routeLine;
    final route = widget.remainingRoute;
    if (map == null || routeLine == null) return;
    await routeLine.deleteAll();
    if (route == null || route.isEmpty) return;
    await routeLine.create(routeLineOptions(route));
    await map.easeTo(
      await cameraOnPath(map, route, bottomPadding: widget.bottomPadding),
      MapAnimationOptions(duration: _cameraAnimation.inMilliseconds),
    );
  }

  Future<void> _showDestination() async {
    final map = _map;
    final destination = widget.destination;
    if (map == null || destination == null) return;
    await showDestinationMarker(map, destination);
  }

  Future<void> _showDriver() async {
    final marker = _driverMarker;
    final position = widget.driverPosition;
    if (marker == null) return;
    await marker.deleteAll();
    if (position == null) return;
    await marker.create(
      CircleAnnotationOptions(
        geometry: position.toPoint(),
        circleColor: AppColors.ink.toARGB32(),
        circleRadius: 9,
        circleStrokeColor: Colors.white.toARGB32(),
        circleStrokeWidth: 3,
      ),
    );
  }
}

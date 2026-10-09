import 'dart:async';

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
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/guidance.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/coordinates_mapbox.dart';
import 'package:mobile/core/widgets/destination_marker.dart';
import 'package:mobile/core/widgets/map_route.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Map of a ride: the taxi coming to the passenger, then driving to the
/// destination along the remaining route, followed by the camera. Shared by
/// the passenger's ride tracking and the driver's guidance.
class RideMap extends StatefulWidget {
  const RideMap({
    required this.origin,
    required this.bottomPadding,
    this.driverPosition,
    this.destination,
    this.remainingRoute,
    this.showsDevicePosition = true,
    this.following,
    this.topPadding = 96,
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

  // The blue dot of the phone's GPS. Off whenever the taxi marker already
  // shows where the phone is: for the driver, and for the passenger in the
  // taxi, whose GPS would not quite agree with the driver's.
  final bool showsDevicePosition;

  // Driving: the camera follows the driver, tilted and turned along the
  // road. Null: the whole remaining route is framed, flat, north up.
  final Guidance? following;

  // Keeps the driver visible below a top banner, while following.
  final double topPadding;

  @override
  State<RideMap> createState() => _RideMapState();
}

class _RideMapState extends State<RideMap> {
  static const _cameraAnimation = Duration(milliseconds: 800);

  // As long as the time between two positions, so the camera glides.
  static const _followingAnimation = Duration(milliseconds: 1000);

  // Created once: MapWidget moves the camera back to a new viewport on
  // every rebuild, which would undo the camera following the taxi.
  late final _viewport = CameraViewportState(
    center: widget.origin.toPoint(),
    zoom: 14,
  );

  MapboxMap? _map;
  PolylineAnnotationManager? _routeLine;
  CircleAnnotationManager? _driverMarker;

  @override
  void didUpdateWidget(RideMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showsDevicePosition != widget.showsDevicePosition) {
      unawaited(_showDevicePosition());
    }
    if (oldWidget.remainingRoute != widget.remainingRoute) _showRoute();
    if (oldWidget.driverPosition != widget.driverPosition) _showDriver();
    if (oldWidget.destination == null) _showDestination();
    if (oldWidget.remainingRoute != widget.remainingRoute ||
        oldWidget.following != widget.following) {
      _moveCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      viewport: _viewport,
      onMapCreated: _onMapCreated,
    );
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await _showDevicePosition();
    // Created first so the route line stays under the taxi marker.
    _routeLine = await map.annotations.createPolylineAnnotationManager();
    _driverMarker = await map.annotations.createCircleAnnotationManager();
    await _showRoute();
    await _showDriver();
    await _showDestination();
    await _moveCamera();
  }

  Future<void> _showDevicePosition() async {
    await _map?.location.updateSettings(
      LocationComponentSettings(
        enabled: widget.showsDevicePosition,
        pulsingEnabled: true,
      ),
    );
  }

  Future<void> _showRoute() async {
    final routeLine = _routeLine;
    final route = widget.remainingRoute;
    if (routeLine == null) return;
    await routeLine.deleteAll();
    if (route == null || route.isEmpty) return;
    await routeLine.create(routeLineOptions(route));
  }

  Future<void> _moveCamera() async {
    final map = _map;
    final route = widget.remainingRoute;
    if (map == null || route == null || route.isEmpty) return;
    final following = widget.following;
    if (following == null) {
      await map.easeTo(
        await cameraOnPath(map, route, bottomPadding: widget.bottomPadding),
        MapAnimationOptions(duration: _cameraAnimation.inMilliseconds),
      );
      return;
    }
    await map.easeTo(
      await cameraFollowing(
        map,
        position: following.position,
        focus: following.maneuverLocation,
        heading: following.heading,
        topPadding: widget.topPadding,
        bottomPadding: widget.bottomPadding,
      ),
      MapAnimationOptions(duration: _followingAnimation.inMilliseconds),
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

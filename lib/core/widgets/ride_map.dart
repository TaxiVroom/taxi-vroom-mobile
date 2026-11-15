import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show
        CameraOptions,
        CameraViewportState,
        CircleAnnotationManager,
        CircleAnnotationOptions,
        IconRotationAlignment,
        LocationComponentSettings,
        MapAnimationOptions,
        MapWidget,
        MapboxMap,
        PointAnnotationManager,
        PointAnnotationOptions,
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
    this.driverHeading,
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

  // Compass direction the taxi drives in, in degrees. Given: the taxi is an
  // arrow turned that way (the driver's own map). Null: a plain dot (the
  // passenger's map).
  final double? driverHeading;

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

  // Framing the whole route, keeps its end (the taxi marker) clear of the
  // panel's edge instead of half under it.
  static const _overviewMargin = 60.0;

  // As long as the time between two positions, so the camera glides.
  static const _followingAnimation = Duration(milliseconds: 1000);

  // Created once: MapWidget moves the camera back to a new viewport on
  // every rebuild, which would undo the camera following the taxi.
  late final _viewport = CameraViewportState(
    center: widget.origin.toPoint(),
    zoom: _zoom,
  );

  static const _zoom = 14.0;

  static const _driverArrowAsset = 'assets/icons/driver_arrow.png';

  // The 72 px image drawn twice as big while following (at its own size it
  // looked tiny), and smaller in the overview, where the map is zoomed out and
  // a big arrow would cover the streets and the route.
  static const _followingArrowScale = 1.7;
  static const _overviewArrowScale = 1.2;

  MapboxMap? _map;
  PolylineAnnotationManager? _routeLine;
  CircleAnnotationManager? _driverMarker;
  PointAnnotationManager? _driverArrow;
  Uint8List? _driverArrowImage;

  @override
  void didUpdateWidget(RideMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showsDevicePosition != widget.showsDevicePosition) {
      unawaited(_showDevicePosition());
    }
    if (oldWidget.remainingRoute != widget.remainingRoute) _showRoute();
    // The arrow's size depends on the view: redraw it when the view changes.
    if (oldWidget.driverPosition != widget.driverPosition ||
        oldWidget.driverHeading != widget.driverHeading ||
        (oldWidget.following == null) != (widget.following == null)) {
      _showDriver();
    }
    if (oldWidget.destination == null) _showDestination();
    // The panel was measured, or changed size: frame again above it.
    if (oldWidget.remainingRoute != widget.remainingRoute ||
        oldWidget.following != widget.following ||
        oldWidget.bottomPadding != widget.bottomPadding) {
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
    // The viewport alone can leave the map on the globe, and a ride without
    // a route (no taxi found) never moves the camera: it is set right away,
    // like PassengerHomeMap does.
    await map.setCamera(
      CameraOptions(center: widget.origin.toPoint(), zoom: _zoom),
    );
    await _showDevicePosition();
    // Created first so the route line stays under the taxi marker.
    _routeLine = await map.annotations.createPolylineAnnotationManager();
    _driverMarker = await map.annotations.createCircleAnnotationManager();
    // The arrow is turned by the taxi's compass heading, so it follows the
    // map and not the screen (the default, "auto", is the screen for a point).
    final arrow = await map.annotations.createPointAnnotationManager();
    await arrow.setIconRotationAlignment(IconRotationAlignment.MAP);
    _driverArrow = arrow;
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
        await cameraOnPath(
          map,
          route,
          bottomPadding: widget.bottomPadding + _overviewMargin,
          topPadding: widget.topPadding,
        ),
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

  // The taxi: an arrow turned by its heading when it is known (the driver's
  // map), a dot otherwise (the passenger's map).
  Future<void> _showDriver() async {
    final dot = _driverMarker;
    final arrow = _driverArrow;
    final position = widget.driverPosition;
    if (dot == null || arrow == null) return;
    await dot.deleteAll();
    await arrow.deleteAll();
    if (position == null) return;
    final heading = widget.driverHeading;
    if (heading == null) {
      await _showDriverDot(dot, position);
    } else {
      await _showDriverArrow(arrow, position, heading);
    }
  }

  Future<void> _showDriverDot(
    CircleAnnotationManager dot,
    Coordinates position,
  ) async {
    await dot.create(
      CircleAnnotationOptions(
        geometry: position.toPoint(),
        circleColor: AppColors.ink.toARGB32(),
        circleRadius: 9,
        circleStrokeColor: Colors.white.toARGB32(),
        circleStrokeWidth: 3,
      ),
    );
  }

  Future<void> _showDriverArrow(
    PointAnnotationManager arrow,
    Coordinates position,
    double heading,
  ) async {
    final image = _driverArrowImage ??= (await rootBundle.load(
      _driverArrowAsset,
    )).buffer.asUint8List();
    await arrow.create(
      PointAnnotationOptions(
        geometry: position.toPoint(),
        image: image,
        iconSize: widget.following == null
            ? _overviewArrowScale
            : _followingArrowScale,
        iconRotate: heading,
      ),
    );
  }
}

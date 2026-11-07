import 'dart:async';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show
        CameraOptions,
        CameraViewportState,
        CircleAnnotationManager,
        CircleAnnotationOptions,
        LocationComponentSettings,
        MapAnimationOptions,
        MapWidget,
        MapboxMap,
        PointAnnotationManager,
        PolylineAnnotationManager,
        ViewportState;
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/coordinates_mapbox.dart';
import 'package:mobile/core/widgets/destination_marker.dart';
import 'package:mobile/core/widgets/map_route.dart';
import 'package:mobile/core/widgets/recenter_button.dart';
import 'package:mobile/features/driver_home/domain/entities/routed_ride_request.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Full-screen map centered on the driver. Online, it shows the roads of an
/// incoming ride request; offline, it is dimmed.
class DriverHomeMap extends StatefulWidget {
  const DriverHomeMap({
    required this.position,
    required this.isOnline,
    required this.bottomPadding,
    required this.panelHeight,
    this.offer,
    super.key,
  });

  final Coordinates position;
  final bool isOnline;

  // Keeps the request's roads visible above the request card.
  final double bottomPadding;

  // Keeps the driver visible above the panel when recentering.
  final double panelHeight;

  // The ride request waiting for the driver's answer, if any.
  final RoutedRideRequest? offer;

  @override
  State<DriverHomeMap> createState() => _DriverHomeMapState();
}

class _DriverHomeMapState extends State<DriverHomeMap> {
  static const _zoom = 14.0;
  static const _cameraAnimation = Duration(milliseconds: 800);
  static const _topBarHeight = 56.0;

  // Replaced only by the recenter button: MapWidget moves the camera back to
  // a new viewport on every rebuild, which would undo the framing of a
  // request.
  late ViewportState _viewport = CameraViewportState(
    center: widget.position.toPoint(),
    zoom: _zoom,
  );

  MapboxMap? _map;
  PolylineAnnotationManager? _approachLine;
  PolylineAnnotationManager? _tripLine;
  CircleAnnotationManager? _pickupMarker;
  PointAnnotationManager? _destinationMarker;

  @override
  void didUpdateWidget(DriverHomeMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offer != widget.offer) unawaited(_showOffer());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: MapWidget(
            viewport: _viewport,
            onMapCreated: _onMapCreated,
          ),
        ),
        // Offline, the map is only a backdrop.
        if (!widget.isOnline)
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: Colors.white.withValues(alpha: 0.45)),
            ),
          ),
        // Below the page's top bar, whose right corner is taken.
        Positioned(
          top: _topBarHeight,
          right: 16,
          child: SafeArea(
            child: RecenterButton(
              onPressed: () => recenterOnDevice(
                (viewport) => _viewport = viewport,
                zoom: _zoom,
                bottomPadding: widget.panelHeight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await map.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
    // Created bottom to top: roads, then the markers above them.
    _approachLine = await map.annotations.createPolylineAnnotationManager();
    await _approachLine?.setLineDasharray([0.5, 2]);
    _tripLine = await map.annotations.createPolylineAnnotationManager();
    _pickupMarker = await map.annotations.createCircleAnnotationManager();
    _destinationMarker = await map.annotations.createPointAnnotationManager();
    await _showOffer();
  }

  Future<void> _showOffer() async {
    final map = _map;
    final approachLine = _approachLine;
    final tripLine = _tripLine;
    final pickupMarker = _pickupMarker;
    final destinationMarker = _destinationMarker;
    if (map == null ||
        approachLine == null ||
        tripLine == null ||
        pickupMarker == null ||
        destinationMarker == null) {
      return;
    }
    await approachLine.deleteAll();
    await tripLine.deleteAll();
    await pickupMarker.deleteAll();
    await destinationMarker.deleteAll();

    final offer = widget.offer;
    if (offer == null) {
      await map.easeTo(
        CameraOptions(center: widget.position.toPoint(), zoom: _zoom),
        MapAnimationOptions(duration: _cameraAnimation.inMilliseconds),
      );
      return;
    }

    final request = offer.request;
    final approach = offer.approach?.path ?? [widget.position, request.pickup];
    final trip = offer.trip?.path ?? [request.pickup, request.destination];
    await approachLine.create(routeLineOptions(approach));
    await tripLine.create(routeLineOptions(trip));
    await pickupMarker.create(
      CircleAnnotationOptions(
        geometry: request.pickup.toPoint(),
        circleColor: Colors.white.toARGB32(),
        circleRadius: 6,
        circleStrokeColor: AppColors.ink.toARGB32(),
        circleStrokeWidth: 4,
      ),
    );
    await destinationMarker.create(
      await destinationMarkerOptions(request.destination),
    );
    await map.easeTo(
      await cameraOnPath(map, [
        ...approach,
        ...trip,
      ], bottomPadding: widget.bottomPadding),
      MapAnimationOptions(duration: _cameraAnimation.inMilliseconds),
    );
  }
}

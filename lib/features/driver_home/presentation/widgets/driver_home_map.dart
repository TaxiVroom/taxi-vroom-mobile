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
        PointAnnotationOptions,
        PolylineAnnotationManager;
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/coordinates_mapbox.dart';
import 'package:mobile/core/widgets/destination_marker.dart';
import 'package:mobile/core/widgets/map_route.dart';
import 'package:mobile/features/driver_home/domain/entities/demand_zone.dart';
import 'package:mobile/features/driver_home/domain/entities/routed_ride_request.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Full-screen map centered on the driver. Online, it shows where passengers
/// are asking for taxis, or the roads of an incoming ride request; offline,
/// it is dimmed.
class DriverHomeMap extends StatefulWidget {
  const DriverHomeMap({
    required this.position,
    required this.isOnline,
    required this.demandZones,
    required this.bottomPadding,
    this.offer,
    super.key,
  });

  final Coordinates position;
  final bool isOnline;
  final List<DemandZone> demandZones;

  // Keeps the request's roads visible above the request card.
  final double bottomPadding;

  // The ride request waiting for the driver's answer, if any.
  final RoutedRideRequest? offer;

  @override
  State<DriverHomeMap> createState() => _DriverHomeMapState();
}

class _DriverHomeMapState extends State<DriverHomeMap> {
  static const _zoneRadius = 55.0;
  static const _zoom = 14.0;
  static const _cameraAnimation = Duration(milliseconds: 800);

  // Created once: MapWidget moves the camera back to a new viewport on
  // every rebuild, which would undo the framing of a request.
  late final _viewport = CameraViewportState(
    center: widget.position.toPoint(),
    zoom: _zoom,
  );

  MapboxMap? _map;
  CircleAnnotationManager? _zones;
  PointAnnotationManager? _zoneNames;
  PolylineAnnotationManager? _approachLine;
  PolylineAnnotationManager? _tripLine;
  CircleAnnotationManager? _pickupMarker;
  PointAnnotationManager? _destinationMarker;

  @override
  void didUpdateWidget(DriverHomeMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOnline != widget.isOnline ||
        oldWidget.demandZones != widget.demandZones ||
        oldWidget.offer != widget.offer) {
      unawaited(_showDemand());
    }
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
      ],
    );
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await map.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
    // Created bottom to top: zones, roads, then the markers above them.
    _zones = await map.annotations.createCircleAnnotationManager();
    _zoneNames = await map.annotations.createPointAnnotationManager();
    _approachLine = await map.annotations.createPolylineAnnotationManager();
    await _approachLine?.setLineDasharray([0.5, 2]);
    _tripLine = await map.annotations.createPolylineAnnotationManager();
    _pickupMarker = await map.annotations.createCircleAnnotationManager();
    _destinationMarker = await map.annotations.createPointAnnotationManager();
    await _showDemand();
    await _showOffer();
  }

  // Hidden while a request is on screen, to keep the map readable.
  Future<void> _showDemand() async {
    final zones = _zones;
    final zoneNames = _zoneNames;
    if (zones == null || zoneNames == null) return;
    await zones.deleteAll();
    await zoneNames.deleteAll();
    if (!widget.isOnline || widget.offer != null) return;

    await zones.createMulti([
      for (final zone in widget.demandZones)
        CircleAnnotationOptions(
          geometry: zone.center.toPoint(),
          circleRadius: _zoneRadius,
          circleColor: (zone.isHigh ? AppColors.star : AppColors.freeTaxi)
              .toARGB32(),
          circleOpacity: zone.isHigh ? 0.25 : 0.18,
        ),
    ]);
    await zoneNames.createMulti([
      for (final zone in widget.demandZones)
        if (zone.name case final name?)
          PointAnnotationOptions(
            geometry: zone.center.toPoint(),
            textField: zone.isHigh ? '$name\nForte demande' : name,
            textSize: 13,
            textColor: AppColors.ink.toARGB32(),
            textHaloColor: Colors.white.toARGB32(),
            textHaloWidth: 2,
          ),
    ]);
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

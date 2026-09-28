import 'dart:async';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show
        CameraViewportState,
        CircleAnnotationManager,
        CircleAnnotationOptions,
        LocationComponentSettings,
        MapWidget,
        MapboxMap,
        ViewportState;
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/coordinates_mapbox.dart';
import 'package:mobile/core/widgets/recenter_button.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Full-screen map centered on the passenger, with the free taxis around.
class PassengerHomeMap extends StatefulWidget {
  const PassengerHomeMap({
    required this.position,
    required this.nearbyTaxis,
    required this.bottomPadding,
    super.key,
  });

  final Coordinates position;
  final List<NearbyTaxi> nearbyTaxis;

  // Keeps the passenger visible above the panel when recentering.
  final double bottomPadding;

  @override
  State<PassengerHomeMap> createState() => _PassengerHomeMapState();
}

class _PassengerHomeMapState extends State<PassengerHomeMap> {
  // Replaced only by "Recentrer": MapWidget moves the camera back to a new
  // viewport on every rebuild, which would undo the passenger's panning.
  late ViewportState _viewport = CameraViewportState(
    center: widget.position.toPoint(),
    zoom: _zoom,
  );

  static const _zoom = 15.0;

  CircleAnnotationManager? _taxiMarkers;

  @override
  void didUpdateWidget(PassengerHomeMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nearbyTaxis != widget.nearbyTaxis) unawaited(_showTaxis());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: MapWidget(viewport: _viewport, onMapCreated: _onMapCreated),
        ),
        Positioned(
          top: 0,
          right: 16,
          child: SafeArea(
            child: RecenterButton(
              onPressed: () => recenterOnDevice(
                (viewport) => _viewport = viewport,
                zoom: _zoom,
                bottomPadding: widget.bottomPadding,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    await map.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
    _taxiMarkers = await map.annotations.createCircleAnnotationManager();
    await _showTaxis();
  }

  // TODO(taxi-glide): taxis jump to their new position every 3 seconds;
  // make them glide from one position to the next, as Uber does.
  Future<void> _showTaxis() async {
    final taxiMarkers = _taxiMarkers;
    if (taxiMarkers == null) return;
    await taxiMarkers.deleteAll();
    await taxiMarkers.createMulti([
      for (final taxi in widget.nearbyTaxis)
        CircleAnnotationOptions(
          geometry: taxi.position.toPoint(),
          circleColor: AppColors.freeTaxi.toARGB32(),
          circleRadius: 7,
          circleStrokeColor: Colors.white.toARGB32(),
          circleStrokeWidth: 2,
        ),
    ]);
  }
}

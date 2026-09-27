import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show
        CameraViewportState,
        CircleAnnotationOptions,
        LocationComponentSettings,
        MapWidget,
        MapboxMap;
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/coordinates_mapbox.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Full-screen map centered on the passenger, with the free taxis around.
class PassengerHomeMap extends StatefulWidget {
  const PassengerHomeMap({
    required this.position,
    required this.nearbyTaxis,
    super.key,
  });

  final Coordinates position;
  final List<NearbyTaxi> nearbyTaxis;

  @override
  State<PassengerHomeMap> createState() => _PassengerHomeMapState();
}

class _PassengerHomeMapState extends State<PassengerHomeMap> {
  // Created once: MapWidget moves the camera back to a new viewport on
  // every rebuild, which would undo the passenger's panning.
  late final _viewport = CameraViewportState(
    center: widget.position.toPoint(),
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    return MapWidget(viewport: _viewport, onMapCreated: _onMapCreated);
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    await map.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
    final taxiMarkers = await map.annotations.createCircleAnnotationManager();
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

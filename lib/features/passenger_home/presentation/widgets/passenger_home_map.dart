import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show
        CameraViewportState,
        CircleAnnotationOptions,
        LocationComponentSettings,
        MapWidget,
        MapboxMap,
        Point,
        Position;
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Full-screen map centered on the passenger, with the free taxis around.
class PassengerHomeMap extends StatelessWidget {
  const PassengerHomeMap({
    required this.position,
    required this.nearbyTaxis,
    super.key,
  });

  final Coordinates position;
  final List<NearbyTaxi> nearbyTaxis;

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      viewport: CameraViewportState(center: _toPoint(position), zoom: 15),
      onMapCreated: _onMapCreated,
    );
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    await map.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
    final taxiMarkers = await map.annotations.createCircleAnnotationManager();
    await taxiMarkers.createMulti([
      for (final taxi in nearbyTaxis)
        CircleAnnotationOptions(
          geometry: _toPoint(taxi.position),
          circleColor: AppColors.freeTaxi.toARGB32(),
          circleRadius: 7,
          circleStrokeColor: Colors.white.toARGB32(),
          circleStrokeWidth: 2,
        ),
    ]);
  }

  static Point _toPoint(Coordinates coordinates) => Point(
        coordinates: Position(coordinates.longitude, coordinates.latitude),
      );
}

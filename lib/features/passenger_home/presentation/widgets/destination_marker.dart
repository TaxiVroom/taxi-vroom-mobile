import 'package:flutter/services.dart' show rootBundle;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show MapboxMap, PointAnnotationOptions;
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/coordinates_mapbox.dart';

const _destinationMarkerAsset = 'assets/icons/destination_marker.png';

/// Draws the arrival marker (dark square), distinct from the blue location
/// puck of the departure.
Future<void> showDestinationMarker(MapboxMap map, Coordinates at) async {
  final markerImage = await rootBundle.load(_destinationMarkerAsset);
  final marker = await map.annotations.createPointAnnotationManager();
  await marker.create(
    PointAnnotationOptions(
      geometry: at.toPoint(),
      image: markerImage.buffer.asUint8List(),
    ),
  );
}

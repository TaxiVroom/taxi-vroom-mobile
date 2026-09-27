import 'package:flutter/services.dart' show rootBundle;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show MapboxMap, PointAnnotationOptions;
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/widgets/coordinates_mapbox.dart';

const _destinationMarkerAsset = 'assets/icons/destination_marker.png';

/// Draws the arrival marker (dark square), distinct from the blue location
/// puck of the departure.
Future<void> showDestinationMarker(MapboxMap map, Coordinates at) async {
  final marker = await map.annotations.createPointAnnotationManager();
  await marker.create(await destinationMarkerOptions(at));
}

/// The arrival marker, for a manager that also removes it later.
Future<PointAnnotationOptions> destinationMarkerOptions(Coordinates at) async {
  final markerImage = await rootBundle.load(_destinationMarkerAsset);
  return PointAnnotationOptions(
    geometry: at.toPoint(),
    image: markerImage.buffer.asUint8List(),
  );
}

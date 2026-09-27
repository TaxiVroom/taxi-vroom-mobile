import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show
        CameraOptions,
        LineString,
        MapboxMap,
        MbxEdgeInsets,
        PolylineAnnotationOptions;
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/presentation/widgets/coordinates_mapbox.dart';

/// The blue route line, drawn with a polyline annotation.
PolylineAnnotationOptions routeLineOptions(List<Coordinates> path) =>
    PolylineAnnotationOptions(
      geometry: LineString(
        coordinates: [for (final point in path) point.toPosition()],
      ),
      lineColor: AppConstants.primaryColor.toARGB32(),
      lineWidth: 5,
    );

/// Camera framing the whole [path] above a bottom panel of [bottomPadding].
Future<CameraOptions> cameraOnPath(
  MapboxMap map,
  List<Coordinates> path, {
  required double bottomPadding,
}) => map.cameraForCoordinatesPadding(
  [for (final point in path) point.toPoint()],
  CameraOptions(),
  MbxEdgeInsets(top: 96, left: 48, bottom: bottomPadding, right: 48),
  16,
  null,
);

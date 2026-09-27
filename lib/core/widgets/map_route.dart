import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show
        CameraOptions,
        LineString,
        MapboxMap,
        MbxEdgeInsets,
        PolylineAnnotationOptions;
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/widgets/coordinates_mapbox.dart';

/// The blue route line, drawn with a polyline annotation.
PolylineAnnotationOptions routeLineOptions(List<Coordinates> path) =>
    PolylineAnnotationOptions(
      geometry: LineString(
        coordinates: [for (final point in path) point.toPosition()],
      ),
      lineColor: AppConstants.primaryColor.toARGB32(),
      lineWidth: 5,
    );

/// Camera framing the whole [path] above a bottom panel of [bottomPadding],
/// flat with the north up: fields left out would keep the map's current
/// rotation and tilt.
Future<CameraOptions> cameraOnPath(
  MapboxMap map,
  List<Coordinates> path, {
  required double bottomPadding,
}) => map.cameraForCoordinatesPadding(
  [for (final point in path) point.toPoint()],
  CameraOptions(bearing: 0, pitch: 0),
  MbxEdgeInsets(top: 96, left: 48, bottom: bottomPadding, right: 48),
  16,
  null,
);

// Mapbox Navigation SDK defaults for the following camera
// (FollowingFrameOptions): tilted to look ahead, and never closer than this.
const _followingPitch = 45.0;
const _followingMaxZoom = 16.35;

/// Driving camera: tilted, turned towards [heading], framing the driver at
/// [position] with the upcoming maneuver at [focus], between a top banner of
/// [topPadding] and a bottom panel of [bottomPadding].
Future<CameraOptions> cameraFollowing(
  MapboxMap map, {
  required Coordinates position,
  required Coordinates focus,
  required double heading,
  required double topPadding,
  required double bottomPadding,
}) => map.cameraForCoordinatesPadding(
  [position.toPoint(), focus.toPoint()],
  CameraOptions(bearing: heading, pitch: _followingPitch),
  MbxEdgeInsets(
    top: topPadding,
    left: 48,
    bottom: bottomPadding,
    right: 48,
  ),
  _followingMaxZoom,
  null,
);

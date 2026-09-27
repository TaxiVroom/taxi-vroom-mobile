import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show Point, Position;
import 'package:mobile/core/domain/entities/coordinates.dart';

extension CoordinatesMapbox on Coordinates {
  // Mapbox (GeoJSON) order: longitude first.
  Position toPosition() => Position(longitude, latitude);

  Point toPoint() => Point(coordinates: toPosition());
}

import 'package:flutter_geo_hash/flutter_geo_hash.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';

// flutter_geo_hash is a young package: these tests check that it computes
// geohashes like Firebase's own GeoFire. The expected values come from the
// official GeoFire tests (github.com/firebase/geofire-js,
// packages/geofire-common/test/Main.test.ts).
void main() {
  final geoHash = GeoHashUtils();

  test('encodes positions like Firebase GeoFire', () {
    // Arrange
    const positions = [
      (-90.0, -180.0, '0000000000'),
      (90.0, 180.0, 'zzzzzzzzzz'),
      (-90.0, 180.0, 'pbpbpbpbpb'),
      (90.0, -180.0, 'bpbpbpbpbp'),
      (37.7853074, -122.4054274, '9q8yywe56g'),
      (38.98719, -77.250783, 'dqcjf17sy6'),
      (29.3760648, 47.9818853, 'tj4p5gerfz'),
      (78.216667, 15.55, 'umghcygjj7'),
      (-54.933333, -67.616667, '4qpzmren1k'),
      (-54.0, -67.0, '4w2kg3s54y'),
    ];

    // Act
    final hashes = [
      for (final (latitude, longitude, _) in positions)
        geoHash.geoHashForLocation(GeoHashPoint(latitude, longitude)),
    ];

    // Assert
    expect(hashes, [for (final (_, _, expected) in positions) expected]);
  });

  test(
    'the ranges around a point contain every position within the radius',
    () {
      // Arrange: the center of Strasbourg and positions less than 2 km away.
      const center = Coordinates(latitude: 48.5734, longitude: 7.7521);
      const radiusMeters = 2000.0;
      const nearby = [
        Coordinates(latitude: 48.5734, longitude: 7.7521),
        Coordinates(latitude: 48.5890, longitude: 7.7521),
        Coordinates(latitude: 48.5734, longitude: 7.7760),
        Coordinates(latitude: 48.5610, longitude: 7.7350),
        Coordinates(latitude: 48.5840, longitude: 7.7680),
      ];

      // Act
      final ranges = geoHash.geohashQueryBounds(
        GeoHashPoint(center.latitude, center.longitude),
        radiusMeters,
      );

      // Assert
      for (final position in nearby) {
        expect(center.distanceTo(position), lessThan(radiusMeters));
        final hash = geoHash.geoHashForLocation(
          GeoHashPoint(position.latitude, position.longitude),
        );
        final isInARange = ranges.any(
          (range) =>
              hash.compareTo(range[0]) >= 0 && hash.compareTo(range[1]) <= 0,
        );
        expect(isInARange, isTrue, reason: '$hash should be found');
      }
    },
  );
}

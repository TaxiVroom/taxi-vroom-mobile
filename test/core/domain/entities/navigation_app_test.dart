import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/navigation_app.dart';

void main() {
  // The pickup of the ride, or its destination.
  const target = Coordinates(latitude: 48.58392, longitude: 7.74553);

  group('NavigationApp directionsTo', () {
    test('Google Maps drives there with its turn-by-turn navigation', () {
      // Act
      final link = NavigationApp.googleMaps.directionsTo(target);

      // Assert: the doc asks for the comma between the coordinates encoded.
      expect(
        link.toString(),
        'https://www.google.com/maps/dir/?api=1'
        '&destination=48.58392%2C7.74553'
        '&travelmode=driving&dir_action=navigate',
      );
    });

    test('Waze starts its navigation there', () {
      // Act
      final link = NavigationApp.waze.directionsTo(target);

      // Assert
      expect(link.host, 'waze.com');
      expect(link.path, '/ul');
      expect(link.queryParameters, {
        'll': '48.58392,7.74553',
        'navigate': 'yes',
      });
    });
  });
}

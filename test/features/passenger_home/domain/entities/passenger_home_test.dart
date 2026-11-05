import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_home.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';

void main() {
  group('PassengerHome', () {
    const phonePosition = Coordinates(latitude: 48.5734, longitude: 7.7521);
    const home = PassengerHome(
      position: phonePosition,
      recentDestinations: [],
    );

    group('pickupAt', () {
      test('no pickup chosen: where the phone is', () {
        // Act
        final pickup = home.pickupAt(null);

        // Assert
        expect(pickup, phonePosition);
      });

      test('a pickup chosen: that place, not the phone', () {
        // Arrange
        const station = Place(
          name: 'Gare de Strasbourg',
          address: '20 Place de la Gare 67000 Strasbourg',
          coordinates: Coordinates(latitude: 48.5851, longitude: 7.7346),
        );

        // Act
        final pickup = home.pickupAt(station);

        // Assert
        expect(pickup, station.coordinates);
      });
    });
  });
}

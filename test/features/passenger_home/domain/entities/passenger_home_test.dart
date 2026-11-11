import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_account.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_home.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';

void main() {
  group('PassengerHome', () {
    const phonePosition = Coordinates(latitude: 48.5734, longitude: 7.7521);
    const home = PassengerHome(position: phonePosition, savedPlaces: []);

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

    group('saved places', () {
      const flat = SavedPlace(
        kind: SavedPlaceKind.home,
        address: '3 Rue du Dôme 67000 Strasbourg',
        coordinates: Coordinates(latitude: 48.5833, longitude: 7.7485),
      );
      const office = SavedPlace(
        kind: SavedPlaceKind.work,
        address: '1 Parc de l’Innovation 67400 Illkirch-Graffenstaden',
        coordinates: Coordinates(latitude: 48.5290, longitude: 7.7360),
      );

      test('nothing saved: no "Maison"', () {
        // Act
        final saved = home.savedPlaceOf(SavedPlaceKind.home);

        // Assert
        expect(saved, isNull);
      });

      test('a "Maison" saved: the shortcut finds it', () {
        // Act
        final saved = home
            .withSavedPlace(flat)
            .savedPlaceOf(SavedPlaceKind.home);

        // Assert
        expect(saved, flat);
      });

      test('a new "Maison" replaces the old one: one of each kind', () {
        // Arrange
        const newFlat = SavedPlace(
          kind: SavedPlaceKind.home,
          address: '20 Place de la Gare 67000 Strasbourg',
          coordinates: Coordinates(latitude: 48.5851, longitude: 7.7346),
        );

        // Act
        final updated = home.withSavedPlace(flat).withSavedPlace(newFlat);

        // Assert
        expect(updated.savedPlaces, [newFlat]);
      });

      test('"Maison" removed: "Travail" stays', () {
        // Arrange
        final both = home.withSavedPlace(flat).withSavedPlace(office);

        // Act
        final updated = both.withoutSavedPlace(SavedPlaceKind.home);

        // Assert
        expect(updated.savedPlaces, [office]);
      });
    });
  });

  group('PassengerAccount', () {
    test('"Maison" removed from "Compte": "Travail" stays', () {
      // Arrange
      const flat = SavedPlace(
        kind: SavedPlaceKind.home,
        address: '4 Rue de la Magel, 67000 Strasbourg, France',
        coordinates: Coordinates(latitude: 48.6108, longitude: 7.7368),
      );
      const office = SavedPlace(
        kind: SavedPlaceKind.work,
        address: '1 Rue Sébastien Brant, 67300 Schiltigheim, France',
        coordinates: Coordinates(latitude: 48.6050, longitude: 7.7470),
      );
      const account = PassengerAccount(
        firstName: 'Jean',
        lastName: 'Dupont',
        phone: '+33612345678',
        email: 'jean@exemple.fr',
        savedPlaces: [flat, office],
      );

      // Act
      final updated = account.withoutSavedPlace(SavedPlaceKind.home);

      // Assert
      expect(updated.savedPlaces, [office]);
    });
  });
}

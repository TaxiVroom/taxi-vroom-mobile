import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';
import 'package:mobile/features/passenger_home/domain/usecases/watch_nearby_taxis_usecase.dart';

void main() {
  group('WatchNearbyTaxisUseCase', () {
    const passenger = Coordinates(latitude: 48.5734, longitude: 7.7521);
    // 1 km north: 1000 / 111195 m per degree of latitude.
    const taxi1KmNorth = NearbyTaxi(
      id: 'taxi-1km',
      position: Coordinates(latitude: 48.5823932, longitude: 7.7521),
      isAvailable: true,
    );
    // 2 km north: 2000 / 111195 m per degree of latitude.
    const taxi2KmNorth = NearbyTaxi(
      id: 'taxi-2km',
      position: Coordinates(latitude: 48.59138642, longitude: 7.7521),
      isAvailable: true,
    );
    // 3 km north: 3000 / 111195 m per degree of latitude.
    const taxi3KmNorth = NearbyTaxi(
      id: 'taxi-3km',
      position: Coordinates(latitude: 48.60037962, longitude: 7.7521),
      isAvailable: true,
    );
    // 6 km north: 6000 / 111195 m per degree of latitude.
    const taxi6KmNorth = NearbyTaxi(
      id: 'taxi-6km',
      position: Coordinates(latitude: 48.6273593, longitude: 7.7521),
      isAvailable: true,
    );

    group('reachableClosestFirst', () {
      test('finds nothing when no taxi is online', () {
        // Arrange
        const taxis = <NearbyTaxi>[];

        // Act
        final reachable = WatchNearbyTaxisUseCase.reachableClosestFirst(
          taxis,
          around: passenger,
        );

        // Assert
        expect(reachable, isEmpty);
      });

      test('finds a taxi within 5 km', () {
        // Arrange
        const taxis = [taxi1KmNorth];

        // Act
        final reachable = WatchNearbyTaxisUseCase.reachableClosestFirst(
          taxis,
          around: passenger,
        );

        // Assert
        expect(reachable, [taxi1KmNorth]);
      });

      test('leaves out a taxi beyond 5 km', () {
        // Arrange
        const taxis = [taxi1KmNorth, taxi6KmNorth];

        // Act
        final reachable = WatchNearbyTaxisUseCase.reachableClosestFirst(
          taxis,
          around: passenger,
        );

        // Assert
        expect(reachable, [taxi1KmNorth]);
      });

      test('keeps a taxi 1 cm within 5 km', () {
        // Arrange
        const taxis = [
          NearbyTaxi(
            id: 'taxi-4999.99m',
            position: Coordinates(latitude: 48.61836599, longitude: 7.7521),
            isAvailable: true,
          ),
        ];

        // Act
        final reachable = WatchNearbyTaxisUseCase.reachableClosestFirst(
          taxis,
          around: passenger,
        );

        // Assert
        expect(reachable, taxis);
      });

      test('leaves out a taxi 1 cm beyond 5 km', () {
        // Arrange
        const taxis = [
          NearbyTaxi(
            id: 'taxi-5000.01m',
            position: Coordinates(latitude: 48.61836617, longitude: 7.7521),
            isAvailable: true,
          ),
        ];

        // Act
        final reachable = WatchNearbyTaxisUseCase.reachableClosestFirst(
          taxis,
          around: passenger,
        );

        // Assert
        expect(reachable, isEmpty);
      });

      test('puts the closest taxi first', () {
        // Arrange
        const taxis = [taxi3KmNorth, taxi1KmNorth];

        // Act
        final reachable = WatchNearbyTaxisUseCase.reachableClosestFirst(
          taxis,
          around: passenger,
        );

        // Assert
        expect(reachable, [taxi1KmNorth, taxi3KmNorth]);
      });

      test('leaves out a taxi already on a ride', () {
        // Arrange
        const busyTaxi1KmNorth = NearbyTaxi(
          id: 'taxi-1km-busy',
          position: Coordinates(latitude: 48.5823932, longitude: 7.7521),
          isAvailable: false,
        );
        const taxis = [busyTaxi1KmNorth, taxi2KmNorth];

        // Act
        final reachable = WatchNearbyTaxisUseCase.reachableClosestFirst(
          taxis,
          around: passenger,
        );

        // Assert
        expect(reachable, [taxi2KmNorth]);
      });
    });
  });
}

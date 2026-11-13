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

    group('searchCenters', () {
      test('starts the search where the passenger is', () async {
        // Arrange
        const positions = Stream<Coordinates>.empty();

        // Act
        final centers = WatchNearbyTaxisUseCase.searchCenters(
          positions,
          from: passenger,
        );

        // Assert
        expect(await centers.toList(), [passenger]);
      });

      test('keeps the search after a move 1 cm within 500 m', () async {
        // Arrange
        final positions = Stream.value(
          const Coordinates(latitude: 48.57789652, longitude: 7.7521),
        );

        // Act
        final centers = WatchNearbyTaxisUseCase.searchCenters(
          positions,
          from: passenger,
        );

        // Assert
        expect(await centers.toList(), [passenger]);
      });

      test('moves the search after a move 1 cm beyond 500 m', () async {
        // Arrange
        const moved = Coordinates(latitude: 48.5778967, longitude: 7.7521);
        final positions = Stream.value(moved);

        // Act
        final centers = WatchNearbyTaxisUseCase.searchCenters(
          positions,
          from: passenger,
        );

        // Assert
        expect(await centers.toList(), [passenger, moved]);
      });

      test('measures the move from the latest search', () async {
        // Arrange
        const moved400mNorth = Coordinates(
          latitude: 48.57699729,
          longitude: 7.7521,
        );
        const moved800mNorth = Coordinates(
          latitude: 48.58059457,
          longitude: 7.7521,
        );
        const moved1100mNorth = Coordinates(
          latitude: 48.58329254,
          longitude: 7.7521,
        );
        final positions = Stream.fromIterable([
          moved400mNorth,
          moved800mNorth,
          moved1100mNorth,
        ]);

        // Act
        final centers = WatchNearbyTaxisUseCase.searchCenters(
          positions,
          from: passenger,
        );

        // Assert
        expect(await centers.toList(), [passenger, moved800mNorth]);
      });
    });

    // A ride refused while taxis were free (too few seats for the
    // passengers) must not be estimated again for the same taxis, or the
    // screen would load forever. Spec taxi-vroom-api/docs/specs/nombre-de-passagers.md,
    // situation 4.
    group('hasNewTaxi', () {
      test('is false when every taxi was already free at the estimate', () {
        // Arrange
        const taxis = [taxi1KmNorth, taxi2KmNorth];
        const known = {'taxi-1km', 'taxi-2km'};

        // Act
        final hasNew = WatchNearbyTaxisUseCase.hasNewTaxi(taxis, known: known);

        // Assert
        expect(hasNew, isFalse);
      });

      test('is true when a taxi was not free at the estimate', () {
        // Arrange
        const taxis = [taxi1KmNorth, taxi2KmNorth];
        const known = {'taxi-1km'};

        // Act
        final hasNew = WatchNearbyTaxisUseCase.hasNewTaxi(taxis, known: known);

        // Assert
        expect(hasNew, isTrue);
      });

      test('is true for the first taxi when none was free before', () {
        // Arrange
        const taxis = [taxi3KmNorth];
        const known = <String>{};

        // Act
        final hasNew = WatchNearbyTaxisUseCase.hasNewTaxi(taxis, known: known);

        // Assert
        expect(hasNew, isTrue);
      });

      test('is false when no taxi is free', () {
        // Arrange
        const taxis = <NearbyTaxi>[];
        const known = {'taxi-1km'};

        // Act
        final hasNew = WatchNearbyTaxisUseCase.hasNewTaxi(taxis, known: known);

        // Assert
        expect(hasNew, isFalse);
      });
    });
  });
}

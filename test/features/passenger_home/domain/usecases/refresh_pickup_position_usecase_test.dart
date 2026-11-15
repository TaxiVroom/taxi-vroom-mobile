import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_home.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/usecases/refresh_pickup_position_usecase.dart';

// The phone's position now, or why it cannot be read; counts the readings.
class _FakeLocationRepository implements LocationRepository {
  _FakeLocationRepository(this.result);

  final Result<Coordinates> result;
  int readings = 0;

  @override
  Future<Result<Coordinates>> getCurrentPosition() async {
    readings++;
    return result;
  }

  @override
  Stream<Result<Coordinates>> watchPosition({bool inBackground = false}) =>
      const Stream.empty();

  @override
  Future<void> openSettings() async {}
}

void main() {
  group('RefreshPickupPositionUseCase', () {
    const atAppOpening = Coordinates(latitude: 48.5851, longitude: 7.7346);
    const now = Coordinates(latitude: 48.6067, longitude: 7.7362);
    const home = PassengerHome(position: atAppOpening, savedPlaces: []);

    test('no pickup chosen: the position of the phone now', () async {
      // Arrange
      final useCase = RefreshPickupPositionUseCase(
        _FakeLocationRepository(const Result.ok(now)),
      );

      // Act
      final result = await useCase(home: home, chosen: null);

      // Assert
      expect(result, isA<Ok<PassengerHome>>());
      expect((result as Ok<PassengerHome>).value.position, now);
    });

    test('a pickup chosen: kept, the phone is not even asked', () async {
      // Arrange
      final location = _FakeLocationRepository(const Result.ok(now));
      final useCase = RefreshPickupPositionUseCase(location);
      const station = Place(
        name: '20 Place de la Gare',
        address: '67000 Strasbourg',
        coordinates: Coordinates(latitude: 48.5851, longitude: 7.7346),
      );

      // Act
      final result = await useCase(home: home, chosen: station);

      // Assert
      expect((result as Ok<PassengerHome>).value, home);
      expect(location.readings, 0);
    });

    test('the position cannot be read: the failure, not the old one', () async {
      // Arrange
      final useCase = RefreshPickupPositionUseCase(
        _FakeLocationRepository(
          const Result.error(LocationFailure('Position introuvable')),
        ),
      );

      // Act
      final result = await useCase(home: home, chosen: null);

      // Assert
      expect(result, isA<Error<PassengerHome>>());
    });

    test('the saved places stay as they were', () async {
      // Arrange
      final useCase = RefreshPickupPositionUseCase(
        _FakeLocationRepository(const Result.ok(now)),
      );

      // Act
      final result = await useCase(home: home, chosen: null);

      // Assert
      expect((result as Ok<PassengerHome>).value.savedPlaces, home.savedPlaces);
    });
  });
}

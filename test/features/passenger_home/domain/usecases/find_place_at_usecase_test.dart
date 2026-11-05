import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/repositories/address_repository.dart';
import 'package:mobile/features/passenger_home/domain/usecases/find_place_at_usecase.dart';

// The address service: knows the point, does not, or cannot be reached.
class _FakeAddressRepository implements AddressRepository {
  _FakeAddressRepository(this.result);

  final Result<Place?> result;

  @override
  Future<Result<Place?>> findPlaceAt(Coordinates point) async => result;
}

void main() {
  group('FindPlaceAtUseCase', () {
    const point = Coordinates(latitude: 48.5851, longitude: 7.7346);

    test('a known address: the place at that address', () async {
      // Arrange
      const station = Place(
        name: '20 Place de la Gare',
        address: '67000 Strasbourg',
        coordinates: point,
      );
      final useCase = FindPlaceAtUseCase(
        _FakeAddressRepository(const Result.ok(station)),
      );

      // Act
      final place = await useCase(point);

      // Assert
      expect(place, station);
    });

    test('no address there: the point stays choosable, unnamed', () async {
      // Arrange
      final useCase = FindPlaceAtUseCase(
        _FakeAddressRepository(const Result.ok(null)),
      );

      // Act
      final place = await useCase(point);

      // Assert
      expect(place, FindPlaceAtUseCase.unknownPlaceAt(point));
      expect(place.coordinates, point);
    });

    test('the service fails: the point stays choosable, unnamed', () async {
      // Arrange
      final useCase = FindPlaceAtUseCase(
        _FakeAddressRepository(
          const Result.error(NetworkFailure('Pas de connexion')),
        ),
      );

      // Act
      final place = await useCase(point);

      // Assert
      expect(place, FindPlaceAtUseCase.unknownPlaceAt(point));
    });
  });
}

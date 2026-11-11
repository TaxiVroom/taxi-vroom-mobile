import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';
import 'package:mobile/features/passenger_home/domain/repositories/saved_place_repository.dart';
import 'package:mobile/features/passenger_home/domain/usecases/add_saved_place_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/find_place_at_usecase.dart';

// Keeps what the app sends to the API, and answers with it.
class _FakeSavedPlaceRepository implements SavedPlaceRepository {
  SavedPlace? added;

  @override
  Future<Result<SavedPlace>> add(SavedPlace place) async {
    added = place;
    return Result.ok(place);
  }

  @override
  Future<Result<SavedPlace>> change(SavedPlace place) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> delete(SavedPlaceKind kind) =>
      throw UnimplementedError();

  @override
  Future<Result<List<SavedPlace>>> getSavedPlaces() =>
      throw UnimplementedError();
}

void main() {
  group('AddSavedPlaceUseCase', () {
    const point = Coordinates(latitude: 48.6108, longitude: 7.7368);

    test('a suggestion chosen: its full address is saved', () async {
      // Arrange
      final repository = _FakeSavedPlaceRepository();
      const street = Place(
        name: '4 Rue de la Magel',
        address: '4 Rue de la Magel, 67000 Strasbourg, France',
        coordinates: point,
      );

      // Act
      await AddSavedPlaceUseCase(repository)(SavedPlaceKind.home, street);

      // Assert
      expect(
        repository.added,
        const SavedPlace(
          kind: SavedPlaceKind.home,
          address: '4 Rue de la Magel, 67000 Strasbourg, France',
          coordinates: point,
        ),
      );
    });

    test('a pin without a known address: refused, nothing sent', () async {
      // Arrange
      final repository = _FakeSavedPlaceRepository();

      // Act
      final result = await AddSavedPlaceUseCase(repository)(
        SavedPlaceKind.home,
        FindPlaceAtUseCase.unknownPlaceAt(point),
      );

      // Assert
      expect(result, isA<Error<SavedPlace>>());
      expect((result as Error<SavedPlace>).error, isA<ValidationFailure>());
      expect(repository.added, isNull);
    });
  });
}

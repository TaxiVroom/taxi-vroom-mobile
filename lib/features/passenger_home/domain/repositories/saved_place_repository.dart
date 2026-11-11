import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';

abstract class SavedPlaceRepository {
  Future<Result<List<SavedPlace>>> getSavedPlaces();

  // The place as the API kept it.
  Future<Result<SavedPlace>> add(SavedPlace place);

  Future<Result<SavedPlace>> change(SavedPlace place);

  Future<Result<void>> delete(SavedPlaceKind kind);
}

import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/place_suggestion.dart';

abstract class PlaceSearchRepository {
  Future<Result<List<PlaceSuggestion>>> suggest({
    required String query,
    required Coordinates near,
  });

  Future<Result<Place>> retrieve(PlaceSuggestion suggestion);
}

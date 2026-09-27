import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place_suggestion.dart';
import 'package:mobile/features/passenger_home/domain/repositories/place_search_repository.dart';

class SuggestDestinationsUseCase {
  const SuggestDestinationsUseCase(this._repository);

  final PlaceSearchRepository _repository;

  // Nothing typed: no search, so no billed request.
  Future<Result<List<PlaceSuggestion>>> call({
    required String query,
    required Coordinates near,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return const Result.ok(<PlaceSuggestion>[]);
    return _repository.suggest(query: trimmedQuery, near: near);
  }
}

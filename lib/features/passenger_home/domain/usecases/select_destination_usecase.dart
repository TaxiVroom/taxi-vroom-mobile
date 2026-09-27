import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/place_suggestion.dart';
import 'package:mobile/features/passenger_home/domain/repositories/place_search_repository.dart';

class SelectDestinationUseCase {
  const SelectDestinationUseCase(this._repository);

  final PlaceSearchRepository _repository;

  Future<Result<Place>> call(PlaceSuggestion suggestion) =>
      _repository.retrieve(suggestion);
}

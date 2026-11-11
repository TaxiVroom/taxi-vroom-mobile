import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';
import 'package:mobile/features/passenger_home/domain/repositories/saved_place_repository.dart';
import 'package:mobile/features/passenger_home/domain/usecases/add_saved_place_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/find_place_at_usecase.dart';

// "Modifier votre domicile", from the "Compte" tab: the same rule as adding.
class ChangeSavedPlaceUseCase {
  const ChangeSavedPlaceUseCase(this._repository);

  final SavedPlaceRepository _repository;

  Future<Result<SavedPlace>> call(SavedPlaceKind kind, Place place) async {
    if (FindPlaceAtUseCase.isUnknown(place)) {
      return const Result.error(AddSavedPlaceUseCase.addressNotFound);
    }
    return _repository.change(SavedPlace.fromPlace(kind, place));
  }
}

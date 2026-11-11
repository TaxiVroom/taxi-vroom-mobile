import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';
import 'package:mobile/features/passenger_home/domain/repositories/saved_place_repository.dart';
import 'package:mobile/features/passenger_home/domain/usecases/find_place_at_usecase.dart';

// "Ajouter votre domicile" or "Ajouter votre lieu de travail". A saved place
// is used for every ride: a pin without a known address is refused.
class AddSavedPlaceUseCase {
  const AddSavedPlaceUseCase(this._repository);

  final SavedPlaceRepository _repository;

  static const addressNotFound = ValidationFailure(
    'Adresse introuvable, choisissez un autre point.',
  );

  Future<Result<SavedPlace>> call(SavedPlaceKind kind, Place place) async {
    if (FindPlaceAtUseCase.isUnknown(place)) {
      return const Result.error(addressNotFound);
    }
    return _repository.add(SavedPlace.fromPlace(kind, place));
  }
}

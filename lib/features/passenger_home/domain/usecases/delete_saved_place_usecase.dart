import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';
import 'package:mobile/features/passenger_home/domain/repositories/saved_place_repository.dart';

// "Supprimer", from the "Compte" tab.
class DeleteSavedPlaceUseCase {
  const DeleteSavedPlaceUseCase(this._repository);

  final SavedPlaceRepository _repository;

  Future<Result<void>> call(SavedPlaceKind kind) => _repository.delete(kind);
}

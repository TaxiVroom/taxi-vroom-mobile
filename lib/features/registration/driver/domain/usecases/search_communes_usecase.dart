import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/registration/driver/domain/entities/commune.dart';
import 'package:mobile/features/registration/driver/domain/repositories/commune_repository.dart';

// "Commune de rattachement" of "Votre taxi".
class SearchCommunesUseCase {
  const SearchCommunesUseCase(this._repository);

  final CommuneRepository _repository;

  // Nothing typed: no search.
  Future<Result<List<Commune>>> call(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return const Result.ok(<Commune>[]);
    return _repository.searchCommunes(trimmed);
  }
}

import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/navigation_app.dart';
import 'package:mobile/core/domain/repositories/navigation_repository.dart';
import 'package:mobile/core/utils/result.dart';

// "Itinéraire": [app] guides the driver to [target], from where they are.
class OpenNavigationUseCase {
  const OpenNavigationUseCase(this._repository);

  final NavigationRepository _repository;

  Future<Result<void>> call(NavigationApp app, Coordinates target) =>
      _repository.open(app.directionsTo(target));
}

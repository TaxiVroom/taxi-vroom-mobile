import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/recent_destination.dart';
import 'package:mobile/features/passenger_home/domain/repositories/recent_destination_repository.dart';

// "Votre trajet": the last 3 different destinations of the passenger's
// completed rides, the most recent first.
class LoadRecentDestinationsUseCase {
  const LoadRecentDestinationsUseCase(this._repository);

  final RecentDestinationRepository _repository;

  Future<Result<List<RecentDestination>>> call() =>
      _repository.getRecentDestinations();
}

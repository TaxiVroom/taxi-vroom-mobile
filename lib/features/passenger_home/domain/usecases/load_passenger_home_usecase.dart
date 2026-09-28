import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_home.dart';
import 'package:mobile/features/passenger_home/domain/entities/recent_destination.dart';
import 'package:mobile/features/passenger_home/domain/repositories/recent_destination_repository.dart';

// Loads the home screen: the passenger's position first, then what depends
// on it. The taxis around come live from WatchNearbyTaxisUseCase.
class LoadPassengerHomeUseCase {
  const LoadPassengerHomeUseCase({
    required LocationRepository locationRepository,
    required RecentDestinationRepository recentDestinationRepository,
  }) : _locationRepository = locationRepository,
       _recentDestinationRepository = recentDestinationRepository;

  final LocationRepository _locationRepository;
  final RecentDestinationRepository _recentDestinationRepository;

  Future<Result<PassengerHome>> call() async {
    final Coordinates position;
    switch (await _locationRepository.getCurrentPosition()) {
      case Ok(:final value):
        position = value;
      case Error(:final error):
        return Result.error(error);
    }

    final List<RecentDestination> recentDestinations;
    switch (await _recentDestinationRepository.getRecentDestinations()) {
      case Ok(:final value):
        recentDestinations = value;
      case Error(:final error):
        return Result.error(error);
    }

    return Result.ok(
      PassengerHome(
        position: position,
        recentDestinations: recentDestinations,
      ),
    );
  }
}

import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/repositories/location_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_home.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';
import 'package:mobile/features/passenger_home/domain/repositories/saved_place_repository.dart';

// Loads the home screen: the passenger's position, then "Maison" and
// "Travail". The taxis around come live from WatchNearbyTaxisUseCase.
class LoadPassengerHomeUseCase {
  const LoadPassengerHomeUseCase({
    required LocationRepository locationRepository,
    required SavedPlaceRepository savedPlaceRepository,
  }) : _locationRepository = locationRepository,
       _savedPlaceRepository = savedPlaceRepository;

  final LocationRepository _locationRepository;
  final SavedPlaceRepository _savedPlaceRepository;

  Future<Result<PassengerHome>> call() async {
    final Coordinates position;
    switch (await _locationRepository.getCurrentPosition()) {
      case Ok(:final value):
        position = value;
      case Error(:final error):
        return Result.error(error);
    }

    final List<SavedPlace> savedPlaces;
    switch (await _savedPlaceRepository.getSavedPlaces()) {
      case Ok(:final value):
        savedPlaces = value;
      case Error(:final error):
        return Result.error(error);
    }

    return Result.ok(
      PassengerHome(position: position, savedPlaces: savedPlaces),
    );
  }
}

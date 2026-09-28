import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';

abstract class NearbyTaxiRepository {
  // The taxis online around [around], again each time one of them changes.
  // May also give a few taxis slightly beyond [radiusMeters].
  Stream<Result<List<NearbyTaxi>>> watchNearbyTaxis({
    required Coordinates around,
    required double radiusMeters,
  });
}

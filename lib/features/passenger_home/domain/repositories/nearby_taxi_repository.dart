import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';

abstract class NearbyTaxiRepository {
  Future<Result<List<NearbyTaxi>>> getNearbyTaxis({
    required Coordinates around,
  });
}

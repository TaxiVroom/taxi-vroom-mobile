import 'package:mobile/features/passenger_home/data/models/nearby_taxi_model.dart';

// No backend endpoint yet: only the fake implementation exists.
abstract class NearbyTaxiRemoteDataSource {
  Future<List<NearbyTaxiModel>> getNearbyTaxis({
    required double latitude,
    required double longitude,
  });
}

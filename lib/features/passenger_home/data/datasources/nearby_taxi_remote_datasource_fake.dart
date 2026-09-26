import 'package:mobile/features/passenger_home/data/datasources/nearby_taxi_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/models/nearby_taxi_model.dart';

/// Implémentation de développement avec données de test.
/// Place quelques taxis autour de la position reçue, pour qu'ils soient visibles partout.
class NearbyTaxiRemoteDataSourceFake implements NearbyTaxiRemoteDataSource {
  // Offsets in degrees (~100 to 600 m) around the passenger.
  static const _offsets = [
    (0.0021, -0.0034),
    (-0.0012, 0.0041),
    (0.0048, 0.0015),
    (-0.0039, -0.0022),
    (0.0007, 0.0058),
    (-0.0051, 0.0009),
  ];

  @override
  Future<List<NearbyTaxiModel>> getNearbyTaxis({
    required double latitude,
    required double longitude,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return [
      for (final (index, (latOffset, lngOffset)) in _offsets.indexed)
        NearbyTaxiModel.fromJson({
          'id': 'fake-taxi-$index',
          'latitude': latitude + latOffset,
          'longitude': longitude + lngOffset,
        }),
    ];
  }
}

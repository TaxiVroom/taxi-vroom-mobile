import 'package:mobile/features/driver_home/data/datasources/demand_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/models/demand_overview_model.dart';

/// Implémentation de développement avec données de test.
/// Place les zones de demande autour de la position reçue, pour qu'elles
/// soient visibles partout.
class DemandRemoteDataSourceFake implements DemandRemoteDataSource {
  @override
  Future<DemandOverviewModel> getDemand({
    required double latitude,
    required double longitude,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return DemandOverviewModel.fromJson({
      'areaName': 'Centre',
      'freeTaxiCount': 3,
      'zones': [
        {
          'latitude': latitude + 0.0060,
          'longitude': longitude + 0.0045,
          'isHigh': true,
          'driveMinutes': 6,
          'name': 'Gare',
        },
        {
          'latitude': latitude + 0.0075,
          'longitude': longitude - 0.0050,
          'isHigh': false,
          'driveMinutes': 8,
        },
        {
          'latitude': latitude - 0.0055,
          'longitude': longitude + 0.0060,
          'isHigh': false,
          'driveMinutes': 7,
        },
      ],
    });
  }
}

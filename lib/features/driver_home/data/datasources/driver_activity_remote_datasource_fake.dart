import 'package:mobile/features/driver_home/data/datasources/driver_activity_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/models/driver_activity_model.dart';

/// Implémentation de développement avec données de test.
/// Garde en mémoire la disponibilité du chauffeur.
class DriverActivityRemoteDataSourceFake
    implements DriverActivityRemoteDataSource {
  bool _isOnline = false;

  @override
  Future<DriverActivityModel> getActivity() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return DriverActivityModel.fromJson({
      'isOnline': _isOnline,
      'todayEarningsCents': 0,
      'weekRideCount': 31,
      'averageRating': 4.9,
      'acceptanceRatePercent': 96,
    });
  }

  @override
  Future<void> setOnline({required bool isOnline}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _isOnline = isOnline;
  }
}

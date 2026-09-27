import 'package:mobile/features/driver_home/data/datasources/driver_activity_remote_datasource.dart';
import 'package:mobile/features/driver_home/data/models/driver_activity_model.dart';

/// Implémentation de développement avec données de test.
/// Garde en mémoire la disponibilité du chauffeur.
class DriverActivityRemoteDataSourceFake
    implements DriverActivityRemoteDataSource {
  bool _isOnline = false;
  bool _receivesBookings = true;

  @override
  Future<DriverActivityModel> getActivity() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return DriverActivityModel.fromJson({
      'isOnline': _isOnline,
      'receivesBookings': _receivesBookings,
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

  @override
  Future<void> setReceivesBookings({required bool receivesBookings}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _receivesBookings = receivesBookings;
  }
}

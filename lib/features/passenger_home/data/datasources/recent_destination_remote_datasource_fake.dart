import 'package:mobile/features/passenger_home/data/datasources/recent_destination_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/models/recent_destination_model.dart';

/// Implémentation de développement avec données de test.
class RecentDestinationRemoteDataSourceFake
    implements RecentDestinationRemoteDataSource {
  static const _json = [
    {
      'name': 'Aéroport Strasbourg-Entzheim',
      'address': 'Entzheim',
      'distanceKm': 14.8,
    },
    {
      'name': 'Parlement européen',
      'address': '1 allée du Printemps',
      'distanceKm': 2.9,
    },
  ];

  @override
  Future<List<RecentDestinationModel>> getRecentDestinations() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _json.map(RecentDestinationModel.fromJson).toList();
  }
}

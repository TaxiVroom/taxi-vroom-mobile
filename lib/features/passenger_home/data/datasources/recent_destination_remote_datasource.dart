import 'package:dio/dio.dart';
import 'package:mobile/features/passenger_home/data/models/recent_destination_model.dart';

abstract class RecentDestinationRemoteDataSource {
  Future<List<RecentDestinationModel>> getRecentDestinations();
}

// The passenger's last 3 different destinations, read again each time "Votre
// trajet" opens. Spec taxi-vroom-api/docs/specs/destinations-recentes.md.
class RecentDestinationRemoteDataSourceImpl
    implements RecentDestinationRemoteDataSource {
  const RecentDestinationRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<RecentDestinationModel>> getRecentDestinations() async {
    final response = await _dio.get<List<dynamic>>(
      '/v1/rides/recent-destinations',
    );
    return [
      for (final json in response.data!)
        RecentDestinationModel.fromJson(json as Map<String, dynamic>),
    ];
  }
}

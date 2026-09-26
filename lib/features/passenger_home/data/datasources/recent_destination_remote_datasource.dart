import 'package:mobile/features/passenger_home/data/models/recent_destination_model.dart';

// No backend endpoint yet: only the fake implementation exists.
abstract class RecentDestinationRemoteDataSource {
  Future<List<RecentDestinationModel>> getRecentDestinations();
}

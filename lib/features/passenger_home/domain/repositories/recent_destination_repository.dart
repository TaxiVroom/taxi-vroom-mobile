import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/recent_destination.dart';

abstract class RecentDestinationRepository {
  Future<Result<List<RecentDestination>>> getRecentDestinations();
}

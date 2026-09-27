import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_route.dart';

abstract class RouteRepository {
  // With [arriveBy], the duration is predicted from the usual traffic to
  // arrive at that time, instead of the live traffic.
  Future<Result<RideRoute>> getRoute({
    required Coordinates from,
    required Coordinates to,
    DateTime? arriveBy,
  });
}

import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/navigation_route.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/core/utils/result.dart';

abstract class RouteRepository {
  // With [arriveBy], the duration is predicted from the usual traffic to
  // arrive at that time, instead of the live traffic.
  Future<Result<RideRoute>> getRoute({
    required Coordinates from,
    required Coordinates to,
    DateTime? arriveBy,
  });

  // With the turn-by-turn steps, to guide a driver on live traffic.
  Future<Result<NavigationRoute>> getNavigationRoute({
    required Coordinates from,
    required Coordinates to,
  });
}

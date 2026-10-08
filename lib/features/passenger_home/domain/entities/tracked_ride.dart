import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';

// A ride update, with the taxi's road: to the passenger, then to the
// destination once in the taxi.
class TrackedRide extends Equatable {
  const TrackedRide({required this.ride, this.remainingRoute});

  final Ride ride;

  // Null without a taxi on its way, or if the route could not be computed.
  final RideRoute? remainingRoute;

  @override
  List<Object?> get props => [ride, remainingRoute];
}

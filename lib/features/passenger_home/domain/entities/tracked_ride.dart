import 'package:equatable/equatable.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_route.dart';

// A ride update, with the road left to the destination once in the taxi.
class TrackedRide extends Equatable {
  const TrackedRide({required this.ride, this.remainingRoute});

  final Ride ride;

  // Null before the ride starts, or if the route could not be computed.
  final RideRoute? remainingRoute;

  @override
  List<Object?> get props => [ride, remainingRoute];
}

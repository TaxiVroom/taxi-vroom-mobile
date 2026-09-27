import 'package:equatable/equatable.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';

// The driving route from the passenger to the destination.
class RideRoute extends Equatable {
  const RideRoute({
    required this.distanceKm,
    required this.durationMinutes,
    required this.path,
  });

  final double distanceKm;
  final int durationMinutes;

  // Points of the route line, in driving order.
  final List<Coordinates> path;

  // Covers the gap between the traffic forecast and the real traffic.
  static const arrivalSafetyMargin = Duration(minutes: 10);

  // "Arriver à" : when the taxi must pick the passenger up to arrive on time.
  DateTime pickupForArrival(DateTime arrival) => arrival
      .subtract(Duration(minutes: durationMinutes))
      .subtract(arrivalSafetyMargin);

  @override
  List<Object?> get props => [distanceKm, durationMinutes, path];
}

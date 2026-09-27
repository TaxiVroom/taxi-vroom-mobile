import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';
import 'package:mobile/features/passenger_home/domain/entities/recent_destination.dart';

// Everything the passenger home screen shows.
class PassengerHome extends Equatable {
  const PassengerHome({
    required this.position,
    required this.nearbyTaxis,
    required this.recentDestinations,
  });

  final Coordinates position;
  final List<NearbyTaxi> nearbyTaxis;
  final List<RecentDestination> recentDestinations;

  @override
  List<Object?> get props => [position, nearbyTaxis, recentDestinations];
}

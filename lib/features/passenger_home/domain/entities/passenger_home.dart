import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/recent_destination.dart';

// Everything the passenger home screen shows.
class PassengerHome extends Equatable {
  const PassengerHome({
    required this.position,
    required this.recentDestinations,
  });

  final Coordinates position;
  final List<RecentDestination> recentDestinations;

  // Where the taxi picks the passenger up: the place they chose, otherwise
  // where the phone is.
  Coordinates pickupAt(Place? chosen) => chosen?.coordinates ?? position;

  @override
  List<Object?> get props => [position, recentDestinations];
}

import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';

// A destination of the passenger's completed rides, offered again in "Votre
// trajet". Spec taxi-vroom-api/docs/specs/destinations-recentes.md.
class RecentDestination extends Equatable {
  const RecentDestination({required this.name, required this.coordinates});

  final String name;
  final Coordinates coordinates;

  // Sent to the estimate as the ride kept it, like a suggestion chosen.
  Place toDestination() =>
      Place(name: name, address: '', coordinates: coordinates);

  @override
  List<Object?> get props => [name, coordinates];
}

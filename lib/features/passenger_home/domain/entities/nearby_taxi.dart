import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';

// A taxi online around the passenger, free or already on a ride.
class NearbyTaxi extends Equatable {
  const NearbyTaxi({
    required this.id,
    required this.position,
    required this.isAvailable,
  });

  final String id;
  final Coordinates position;
  final bool isAvailable;

  @override
  List<Object?> get props => [id, position, isAvailable];
}

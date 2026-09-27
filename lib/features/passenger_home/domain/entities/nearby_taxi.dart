import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';

// A free taxi around the passenger.
class NearbyTaxi extends Equatable {
  const NearbyTaxi({required this.id, required this.position});

  final String id;
  final Coordinates position;

  @override
  List<Object?> get props => [id, position];
}

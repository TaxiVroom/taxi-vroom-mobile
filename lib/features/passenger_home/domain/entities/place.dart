import 'package:equatable/equatable.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';

// A chosen destination, with its exact position.
class Place extends Equatable {
  const Place({
    required this.name,
    required this.address,
    required this.coordinates,
  });

  final String name;
  final String address;
  final Coordinates coordinates;

  @override
  List<Object?> get props => [name, address, coordinates];
}

import 'package:equatable/equatable.dart';

// The taxi driver assigned to a ride.
class Driver extends Equatable {
  const Driver({
    required this.name,
    required this.rating,
    required this.completedRides,
    required this.taxiNumber,
    required this.city,
  });

  final String name;
  final double rating;
  final int completedRides;

  // Licence number of the taxi in its city (e.g. "118").
  final String taxiNumber;
  final String city;

  @override
  List<Object?> get props => [name, rating, completedRides, taxiNumber, city];
}

import 'package:equatable/equatable.dart';

// The taxi driver assigned to a ride. Their taxi is the ride's Vehicle.
class Driver extends Equatable {
  const Driver({
    required this.name,
    required this.rating,
    required this.completedRides,
  });

  final String name;

  // The average of all their ratings: null until they get one.
  final double? rating;
  final int completedRides;

  @override
  List<Object?> get props => [name, rating, completedRides];
}

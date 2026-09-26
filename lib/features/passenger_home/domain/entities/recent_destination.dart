import 'package:equatable/equatable.dart';

class RecentDestination extends Equatable {
  const RecentDestination({
    required this.name,
    required this.address,
    required this.distanceKm,
  });

  final String name;
  final String address;

  // Distance from the passenger's current position.
  final double distanceKm;

  @override
  List<Object?> get props => [name, address, distanceKm];
}

import 'package:equatable/equatable.dart';

// An address suggested while the passenger types a destination.
class PlaceSuggestion extends Equatable {
  const PlaceSuggestion({
    required this.id,
    required this.name,
    required this.address,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String address;

  // Distance from the passenger, when the search provider gives it.
  final double? distanceKm;

  @override
  List<Object?> get props => [id, name, address, distanceKm];
}

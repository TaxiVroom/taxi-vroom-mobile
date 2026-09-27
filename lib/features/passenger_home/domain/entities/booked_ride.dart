import 'package:equatable/equatable.dart';

// A ride booked in advance, not started yet.
class BookedRide extends Equatable {
  const BookedRide({
    required this.id,
    required this.originName,
    required this.destinationName,
    required this.scheduledPickup,
    required this.offerName,
    required this.minPriceCents,
    required this.maxPriceCents,
  });

  final String id;
  final String originName;
  final String destinationName;
  final DateTime scheduledPickup;
  final String offerName;

  // Estimate shown when booking: the meter decides the final price.
  final int minPriceCents;
  final int maxPriceCents;

  @override
  List<Object?> get props => [
    id,
    originName,
    destinationName,
    scheduledPickup,
    offerName,
    minPriceCents,
    maxPriceCents,
  ];
}

import 'package:equatable/equatable.dart';

// A ride booked in advance, seen from the driver's side.
class DriverBooking extends Equatable {
  const DriverBooking({
    required this.id,
    required this.scheduledPickup,
    required this.pickupName,
    required this.destinationName,
    required this.distanceKm,
    required this.minPriceCents,
    required this.maxPriceCents,
    required this.customerFirstName,
    required this.passengerCount,
    required this.luggageCount,
    this.canDepart = false,
    this.requirement,
  });

  final String id;
  final DateTime scheduledPickup;
  final String pickupName;
  final String destinationName;
  final double distanceKm;

  // Estimated on the meter: the real price is only known on arrival.
  final int minPriceCents;
  final int maxPriceCents;

  final String customerFirstName;
  final int passengerCount;
  final int luggageCount;

  // Its deadline passed and it is the driver's: "Je pars" replaces
  // "Se désister".
  final bool canDepart;

  // A need the taxi must meet, e.g. "Taxi Accès demandé".
  final String? requirement;

  @override
  List<Object?> get props => [
    id,
    scheduledPickup,
    pickupName,
    destinationName,
    distanceKm,
    minPriceCents,
    maxPriceCents,
    customerFirstName,
    passengerCount,
    luggageCount,
    canDepart,
    requirement,
  ];
}

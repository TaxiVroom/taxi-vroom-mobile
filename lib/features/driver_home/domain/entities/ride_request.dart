import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';

// A passenger asks for a taxi right now, or their booking starts: offered to
// the driver, who must answer before the time runs out.
class RideRequest extends Equatable {
  const RideRequest({
    required this.id,
    required this.sentAt,
    required this.minPriceCents,
    required this.maxPriceCents,
    required this.distanceKm,
    required this.pickupName,
    required this.pickup,
    required this.destinationName,
    required this.destination,
    required this.customerFirstName,
    required this.customerRating,
    required this.passengerCount,
    required this.luggageCount,
    this.scheduledPickup,
  });

  // After this, the request goes to another driver.
  static const responseTime = Duration(seconds: 15);

  final String id;
  final DateTime sentAt;

  // Estimated on the meter: the real price is only known on arrival.
  final int minPriceCents;
  final int maxPriceCents;

  // From the pickup to the destination.
  final double distanceKm;

  final String pickupName;
  final Coordinates pickup;
  final String destinationName;
  final Coordinates destination;
  final String customerFirstName;
  final double customerRating;
  final int passengerCount;
  final int luggageCount;

  // Only for a booking: when the passenger waits for the taxi.
  final DateTime? scheduledPickup;

  // Whole seconds left to answer, never below 0.
  int secondsLeft(DateTime now) {
    final left = sentAt.add(responseTime).difference(now);
    if (left <= Duration.zero) return 0;
    return (left.inMilliseconds / 1000).ceil();
  }

  bool isExpired(DateTime now) => secondsLeft(now) == 0;

  @override
  List<Object?> get props => [
    id,
    sentAt,
    minPriceCents,
    maxPriceCents,
    distanceKm,
    pickupName,
    pickup,
    destinationName,
    destination,
    customerFirstName,
    customerRating,
    passengerCount,
    luggageCount,
    scheduledPickup,
  ];
}

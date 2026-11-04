import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_request.dart';

class RideRequestModel {
  const RideRequestModel({
    required this.id,
    required this.sentAt,
    required this.minPriceCents,
    required this.maxPriceCents,
    required this.distanceKm,
    required this.pickupName,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationName,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.customerFirstName,
    required this.customerRating,
    required this.passengerCount,
    required this.luggageCount,
    required this.scheduledPickup,
  });

  factory RideRequestModel.fromJson(Map<String, dynamic> json) {
    final pickup = json['pickup'] as Map<String, dynamic>;
    final destination = json['destination'] as Map<String, dynamic>;
    final customer = json['customer'] as Map<String, dynamic>;
    final scheduledPickup = json['scheduledPickup'] as String?;
    return RideRequestModel(
      id: json['id'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      minPriceCents: json['minPriceCents'] as int,
      maxPriceCents: json['maxPriceCents'] as int,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      pickupName: pickup['name'] as String,
      pickupLatitude: (pickup['latitude'] as num).toDouble(),
      pickupLongitude: (pickup['longitude'] as num).toDouble(),
      destinationName: destination['name'] as String,
      destinationLatitude: (destination['latitude'] as num).toDouble(),
      destinationLongitude: (destination['longitude'] as num).toDouble(),
      customerFirstName: customer['firstName'] as String,
      customerRating: (customer['rating'] as num).toDouble(),
      passengerCount: json['passengerCount'] as int,
      luggageCount: json['luggageCount'] as int,
      scheduledPickup: scheduledPickup == null
          ? null
          : DateTime.parse(scheduledPickup),
    );
  }

  final String id;
  final DateTime sentAt;
  final int minPriceCents;
  final int maxPriceCents;
  final double distanceKm;
  final String pickupName;
  final double pickupLatitude;
  final double pickupLongitude;
  final String destinationName;
  final double destinationLatitude;
  final double destinationLongitude;
  final String customerFirstName;
  final double customerRating;
  final int passengerCount;
  final int luggageCount;

  // Only for a booking.
  final DateTime? scheduledPickup;

  RideRequest toDomain() => RideRequest(
    id: id,
    sentAt: sentAt,
    minPriceCents: minPriceCents,
    maxPriceCents: maxPriceCents,
    distanceKm: distanceKm,
    pickupName: pickupName,
    pickup: Coordinates(latitude: pickupLatitude, longitude: pickupLongitude),
    destinationName: destinationName,
    destination: Coordinates(
      latitude: destinationLatitude,
      longitude: destinationLongitude,
    ),
    customerFirstName: customerFirstName,
    customerRating: customerRating,
    passengerCount: passengerCount,
    luggageCount: luggageCount,
    scheduledPickup: scheduledPickup,
  );
}

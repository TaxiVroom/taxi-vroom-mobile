import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';

class DriverBookingModel {
  const DriverBookingModel({
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
    required this.requirement,
  });

  factory DriverBookingModel.fromJson(Map<String, dynamic> json) =>
      DriverBookingModel(
        id: json['id'] as String,
        scheduledPickup: DateTime.parse(json['scheduledPickup'] as String),
        pickupName: json['pickupName'] as String,
        destinationName: json['destinationName'] as String,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        minPriceCents: json['minPriceCents'] as int,
        maxPriceCents: json['maxPriceCents'] as int,
        customerFirstName: json['customerFirstName'] as String,
        passengerCount: json['passengerCount'] as int,
        luggageCount: json['luggageCount'] as int,
        requirement: json['requirement'] as String?,
      );

  final String id;
  final DateTime scheduledPickup;
  final String pickupName;
  final String destinationName;
  final double distanceKm;
  final int minPriceCents;
  final int maxPriceCents;
  final String customerFirstName;
  final int passengerCount;
  final int luggageCount;
  final String? requirement;

  DriverBooking toDomain() => DriverBooking(
    id: id,
    scheduledPickup: scheduledPickup,
    pickupName: pickupName,
    destinationName: destinationName,
    distanceKm: distanceKm,
    minPriceCents: minPriceCents,
    maxPriceCents: maxPriceCents,
    customerFirstName: customerFirstName,
    passengerCount: passengerCount,
    luggageCount: luggageCount,
    requirement: requirement,
  );
}

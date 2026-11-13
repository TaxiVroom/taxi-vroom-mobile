import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';

// From GET /v1/bookings/available and /accepted.
class DriverBookingModel {
  const DriverBookingModel({
    required this.id,
    required this.scheduledPickup,
    required this.pickupName,
    required this.destinationName,
    required this.tripMeters,
    required this.minPriceCents,
    required this.maxPriceCents,
    required this.customerFirstName,
    required this.passengerCount,
    required this.canDepart,
  });

  factory DriverBookingModel.fromJson(Map<String, dynamic> json) =>
      DriverBookingModel(
        id: json['id'] as String,
        scheduledPickup: DateTime.parse(json['pickupAt'] as String).toLocal(),
        pickupName: json['originName'] as String,
        destinationName: json['destinationName'] as String,
        tripMeters: json['tripMeters'] as int,
        minPriceCents: json['estimatedPriceMinCents'] as int,
        maxPriceCents: json['estimatedPriceMaxCents'] as int,
        customerFirstName: json['passengerFirstName'] as String,
        passengerCount: json['passengerCount'] as int,
        canDepart: json['canDepart'] as bool,
      );

  final String id;
  final DateTime scheduledPickup;
  final String pickupName;
  final String destinationName;
  final int tripMeters;
  final int minPriceCents;
  final int maxPriceCents;
  final String customerFirstName;
  final int passengerCount;
  final bool canDepart;

  DriverBooking toDomain() => DriverBooking(
    id: id,
    scheduledPickup: scheduledPickup,
    pickupName: pickupName,
    destinationName: destinationName,
    distanceKm: tripMeters / 1000,
    minPriceCents: minPriceCents,
    maxPriceCents: maxPriceCents,
    customerFirstName: customerFirstName,
    passengerCount: passengerCount,
    canDepart: canDepart,
  );
}

import 'package:mobile/features/passenger_home/domain/entities/booked_ride.dart';

// From GET /v1/rides/booked.
class BookedRideModel {
  const BookedRideModel({
    required this.id,
    required this.originName,
    required this.destinationName,
    required this.scheduledPickup,
    required this.minPriceCents,
    required this.maxPriceCents,
    required this.driverFirstName,
  });

  factory BookedRideModel.fromJson(Map<String, dynamic> json) =>
      BookedRideModel(
        id: json['id'] as String,
        originName: json['originName'] as String,
        destinationName: json['destinationName'] as String,
        scheduledPickup: DateTime.parse(json['pickupAt'] as String).toLocal(),
        minPriceCents: json['estimatedPriceMinCents'] as int,
        maxPriceCents: json['estimatedPriceMaxCents'] as int,
        driverFirstName: json['driverFirstName'] as String?,
      );

  // The backend only knows the plain taxi.
  static const _offerName = 'Taxi';

  final String id;
  final String originName;
  final String destinationName;
  final DateTime scheduledPickup;
  final int minPriceCents;
  final int maxPriceCents;
  final String? driverFirstName;

  BookedRide toDomain() => BookedRide(
    id: id,
    originName: originName,
    destinationName: destinationName,
    scheduledPickup: scheduledPickup,
    offerName: _offerName,
    minPriceCents: minPriceCents,
    maxPriceCents: maxPriceCents,
    driverFirstName: driverFirstName,
  );
}

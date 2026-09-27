import 'package:mobile/features/passenger_home/domain/entities/booked_ride.dart';

class BookedRideModel {
  const BookedRideModel({
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
  final int minPriceCents;
  final int maxPriceCents;

  factory BookedRideModel.fromJson(Map<String, dynamic> json) =>
      BookedRideModel(
        id: json['id'] as String,
        originName: json['originName'] as String,
        destinationName: json['destinationName'] as String,
        scheduledPickup: DateTime.parse(json['scheduledPickup'] as String),
        offerName: json['offerName'] as String,
        minPriceCents: json['minPriceCents'] as int,
        maxPriceCents: json['maxPriceCents'] as int,
      );

  BookedRide toDomain() => BookedRide(
    id: id,
    originName: originName,
    destinationName: destinationName,
    scheduledPickup: scheduledPickup,
    offerName: offerName,
    minPriceCents: minPriceCents,
    maxPriceCents: maxPriceCents,
  );
}

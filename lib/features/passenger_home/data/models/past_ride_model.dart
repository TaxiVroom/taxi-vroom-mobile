import 'package:mobile/features/passenger_home/domain/entities/past_ride.dart';

class PastRideModel {
  const PastRideModel({
    required this.id,
    required this.originName,
    required this.destinationName,
    required this.startedAt,
    required this.tariff,
    required this.totalCents,
  });

  factory PastRideModel.fromJson(Map<String, dynamic> json) => PastRideModel(
    id: json['id'] as String,
    originName: json['originName'] as String,
    destinationName: json['destinationName'] as String,
    startedAt: DateTime.parse(json['startedAt'] as String),
    tariff: json['tariff'] as String,
    totalCents: json['totalCents'] as int,
  );

  final String id;
  final String originName;
  final String destinationName;
  final DateTime startedAt;
  final String tariff;
  final int totalCents;

  PastRide toDomain() => PastRide(
    id: id,
    originName: originName,
    destinationName: destinationName,
    startedAt: startedAt,
    tariff: tariff,
    totalCents: totalCents,
  );
}

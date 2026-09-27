import 'package:mobile/features/driver_home/domain/entities/meter_reading.dart';

class MeterReadingModel {
  const MeterReadingModel({
    required this.tariff,
    required this.amountCents,
    required this.distanceKm,
  });

  factory MeterReadingModel.fromJson(Map<String, dynamic> json) =>
      MeterReadingModel(
        tariff: json['tariff'] as String,
        amountCents: json['amountCents'] as int,
        distanceKm: (json['distanceKm'] as num).toDouble(),
      );

  final String tariff;
  final int amountCents;
  final double distanceKm;

  MeterReading toDomain() => MeterReading(
    tariff: tariff,
    amountCents: amountCents,
    distanceKm: distanceKm,
  );
}

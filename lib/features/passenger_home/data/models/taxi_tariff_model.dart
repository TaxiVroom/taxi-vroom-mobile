import 'package:mobile/features/passenger_home/domain/entities/taxi_tariff.dart';

class TaxiTariffModel {
  const TaxiTariffModel({
    required this.departmentCode,
    required this.validFrom,
    required this.decree,
    required this.pickupCents,
    required this.kmCentsA,
    required this.kmCentsB,
    required this.kmCentsC,
    required this.kmCentsD,
    required this.hourlyCents,
    required this.minimumFareCents,
    required this.nightStartMinute,
    required this.nightEndMinute,
  });

  factory TaxiTariffModel.fromJson(Map<String, dynamic> json) =>
      TaxiTariffModel(
        departmentCode: json['departmentCode'] as String,
        validFrom: DateTime.parse(json['validFrom'] as String),
        decree: json['decree'] as String,
        pickupCents: json['pickupCents'] as int,
        kmCentsA: json['kmCentsA'] as int,
        kmCentsB: json['kmCentsB'] as int,
        kmCentsC: json['kmCentsC'] as int,
        kmCentsD: json['kmCentsD'] as int,
        hourlyCents: json['hourlyCents'] as int,
        minimumFareCents: json['minimumFareCents'] as int,
        nightStartMinute: json['nightStartMinute'] as int,
        nightEndMinute: json['nightEndMinute'] as int,
      );

  final String departmentCode;
  final DateTime validFrom;
  final String decree;
  final int pickupCents;
  final int kmCentsA;
  final int kmCentsB;
  final int kmCentsC;
  final int kmCentsD;
  final int hourlyCents;
  final int minimumFareCents;
  final int nightStartMinute;
  final int nightEndMinute;

  TaxiTariff toDomain() => TaxiTariff(
    departmentCode: departmentCode,
    validFrom: validFrom,
    decree: decree,
    pickupCents: pickupCents,
    kmCentsA: kmCentsA,
    kmCentsB: kmCentsB,
    kmCentsC: kmCentsC,
    kmCentsD: kmCentsD,
    hourlyCents: hourlyCents,
    minimumFareCents: minimumFareCents,
    nightStartMinute: nightStartMinute,
    nightEndMinute: nightEndMinute,
  );
}

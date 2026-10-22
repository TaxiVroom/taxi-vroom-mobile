import 'package:equatable/equatable.dart';

// The regulated taxi tariffs the estimate was computed with, from the
// département's prefectural arrêté.
class TaxiTariff extends Equatable {
  const TaxiTariff({
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

  final String departmentCode;
  final DateTime validFrom;
  final String decree;
  final int pickupCents;

  // A by day, B by night, the taxi returning with a passenger; C by day, D
  // by night, the taxi returning empty.
  final int kmCentsA;
  final int kmCentsB;
  final int kmCentsC;
  final int kmCentsD;

  // Charged instead of the km price while the taxi is slow or stopped.
  final int hourlyCents;
  final int minimumFareCents;

  // Minutes since midnight. The night tariffs also apply all day on Sundays
  // and public holidays.
  final int nightStartMinute;
  final int nightEndMinute;

  @override
  List<Object?> get props => [
    departmentCode,
    validFrom,
    decree,
    pickupCents,
    kmCentsA,
    kmCentsB,
    kmCentsC,
    kmCentsD,
    hourlyCents,
    minimumFareCents,
    nightStartMinute,
    nightEndMinute,
  ];
}

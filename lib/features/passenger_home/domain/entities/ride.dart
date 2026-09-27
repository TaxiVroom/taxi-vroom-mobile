import 'package:equatable/equatable.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/driver.dart';
import 'package:mobile/features/passenger_home/domain/entities/fare_line.dart';
import 'package:mobile/features/passenger_home/domain/entities/vehicle.dart';

// An ordered ride, one subtype per status: the compiler forces every screen
// to handle each of them.
sealed class Ride extends Equatable {
  const Ride({required this.id});

  final String id;
}

final class RideSearchingDriver extends Ride {
  const RideSearchingDriver({required super.id});

  @override
  List<Object?> get props => [id];
}

final class RideDriverApproaching extends Ride {
  const RideDriverApproaching({
    required super.id,
    required this.driver,
    required this.vehicle,
    required this.driverPosition,
    required this.etaMinutes,
    required this.boardingCode,
  });

  final Driver driver;
  final Vehicle vehicle;
  final Coordinates driverPosition;
  final int etaMinutes;

  // Given to the driver when boarding, so the passenger takes the right taxi.
  final String boardingCode;

  @override
  List<Object?> get props => [
    id,
    driver,
    vehicle,
    driverPosition,
    etaMinutes,
    boardingCode,
  ];
}

// The passenger is in the taxi, the meter is running.
final class RideInProgress extends Ride {
  const RideInProgress({
    required super.id,
    required this.driver,
    required this.vehicle,
    required this.taxiPosition,
    required this.destination,
    required this.meterCents,
    required this.tariff,
    required this.remainingKm,
    required this.estimatedArrival,
  });

  final Driver driver;
  final Vehicle vehicle;
  final Coordinates taxiPosition;
  final Coordinates destination;

  // Live amount on the taxi's meter.
  final int meterCents;

  // Regulated tariff currently applied by the meter (A, B, C or D).
  final String tariff;
  final double remainingKm;
  final DateTime estimatedArrival;

  @override
  List<Object?> get props => [
    id,
    driver,
    vehicle,
    taxiPosition,
    destination,
    meterCents,
    tariff,
    remainingKm,
    estimatedArrival,
  ];
}

final class RideCompleted extends Ride {
  const RideCompleted({
    required super.id,
    required this.driver,
    required this.destinationName,
    required this.arrivedAt,
    required this.totalCents,
    required this.fareLines,
  });

  final Driver driver;
  final String destinationName;
  final DateTime arrivedAt;

  // Final amount on the meter: what the passenger pays.
  final int totalCents;
  final List<FareLine> fareLines;

  @override
  List<Object?> get props => [
    id,
    driver,
    destinationName,
    arrivedAt,
    totalCents,
    fareLines,
  ];
}

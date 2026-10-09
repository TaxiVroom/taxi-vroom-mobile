import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
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

// Every free taxi around was asked, none took the ride.
final class RideNoDriverFound extends Ride {
  const RideNoDriverFound({required super.id});

  @override
  List<Object?> get props => [id];
}

// The driver waited at the pickup and reported the passenger absent.
final class RidePassengerNoShow extends Ride {
  const RidePassengerNoShow({required super.id});

  @override
  List<Object?> get props => [id];
}

final class RideDriverApproaching extends Ride {
  const RideDriverApproaching({
    required super.id,
    required this.driver,
    required this.vehicle,
    required this.pickup,
    required this.driverPosition,
    required this.boardingCode,
    this.etaMinutes,
  });

  final Driver driver;
  final Vehicle vehicle;

  // Where the driver picks the passenger up.
  final Coordinates pickup;
  final Coordinates driverPosition;

  // From the driver's road to the pickup: null until it is known.
  final int? etaMinutes;

  // Given to the driver when boarding, so the passenger takes the right taxi.
  final String boardingCode;

  RideDriverApproaching withEtaMinutes(int etaMinutes) => RideDriverApproaching(
    id: id,
    driver: driver,
    vehicle: vehicle,
    pickup: pickup,
    driverPosition: driverPosition,
    boardingCode: boardingCode,
    etaMinutes: etaMinutes,
  );

  @override
  List<Object?> get props => [
    id,
    driver,
    vehicle,
    pickup,
    driverPosition,
    etaMinutes,
    boardingCode,
  ];
}

// The taxi waits at the pickup for the passenger to give their code.
final class RideDriverArrived extends Ride {
  const RideDriverArrived({
    required super.id,
    required this.driver,
    required this.vehicle,
    required this.driverPosition,
    required this.boardingCode,
  });

  final Driver driver;
  final Vehicle vehicle;
  final Coordinates driverPosition;
  final String boardingCode;

  @override
  List<Object?> get props => [
    id,
    driver,
    vehicle,
    driverPosition,
    boardingCode,
  ];
}

// The passenger is in the taxi. The meter is not connected yet: the
// passenger sees the price estimated when ordering.
final class RideInProgress extends Ride {
  const RideInProgress({
    required super.id,
    required this.driver,
    required this.vehicle,
    required this.taxiPosition,
    required this.destination,
    required this.minPriceCents,
    required this.maxPriceCents,
    this.estimatedArrival,
  });

  final Driver driver;
  final Vehicle vehicle;
  final Coordinates taxiPosition;
  final Coordinates destination;
  final int minPriceCents;
  final int maxPriceCents;

  // From the taxi's road to the destination: null until it is known.
  final DateTime? estimatedArrival;

  RideInProgress withEstimatedArrival(DateTime estimatedArrival) =>
      RideInProgress(
        id: id,
        driver: driver,
        vehicle: vehicle,
        taxiPosition: taxiPosition,
        destination: destination,
        minPriceCents: minPriceCents,
        maxPriceCents: maxPriceCents,
        estimatedArrival: estimatedArrival,
      );

  @override
  List<Object?> get props => [
    id,
    driver,
    vehicle,
    taxiPosition,
    destination,
    minPriceCents,
    maxPriceCents,
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

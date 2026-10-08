import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/driver.dart';
import 'package:mobile/features/passenger_home/domain/entities/fare_line.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/vehicle.dart';

sealed class RideModel {
  const RideModel({required this.id});

  factory RideModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final status = json['status'] as String;
    return switch (status) {
      'SEARCHING_DRIVER' => SearchingDriverRideModel(id: id),
      'NO_DRIVER_FOUND' => NoDriverFoundRideModel(id: id),
      'DRIVER_APPROACHING' => DriverApproachingRideModel(json),
      'IN_PROGRESS' => InProgressRideModel(json),
      'COMPLETED' => CompletedRideModel(json),
      _ => throw FormatException('Statut de course inconnu : $status'),
    };
  }

  final String id;

  Ride toDomain();
}

final class SearchingDriverRideModel extends RideModel {
  const SearchingDriverRideModel({required super.id});

  @override
  Ride toDomain() => RideSearchingDriver(id: id);
}

final class NoDriverFoundRideModel extends RideModel {
  const NoDriverFoundRideModel({required super.id});

  @override
  Ride toDomain() => RideNoDriverFound(id: id);
}

final class DriverApproachingRideModel extends RideModel {
  DriverApproachingRideModel(this._json) : super(id: _json['id'] as String);

  final Map<String, dynamic> _json;

  @override
  Ride toDomain() => RideDriverApproaching(
    id: id,
    driver: _driverFromJson(_json['driver']),
    vehicle: _vehicleFromJson(_json['vehicle']),
    pickup: _coordinatesFromJson(_json['pickup']),
    driverPosition: _coordinatesFromJson(_json['driverPosition']),
    // Known later, from the driver's road to the pickup.
    etaMinutes: _json['etaMinutes'] as int?,
    boardingCode: _json['boardingCode'] as String,
  );
}

final class InProgressRideModel extends RideModel {
  InProgressRideModel(this._json) : super(id: _json['id'] as String);

  final Map<String, dynamic> _json;

  @override
  Ride toDomain() => RideInProgress(
    id: id,
    driver: _driverFromJson(_json['driver']),
    vehicle: _vehicleFromJson(_json['vehicle']),
    taxiPosition: _coordinatesFromJson(_json['taxiPosition']),
    destination: _coordinatesFromJson(_json['destination']),
    meterCents: _json['meterCents'] as int,
    tariff: _json['tariff'] as String,
    remainingKm: (_json['remainingKm'] as num).toDouble(),
    estimatedArrival: DateTime.parse(_json['estimatedArrival'] as String),
  );
}

final class CompletedRideModel extends RideModel {
  CompletedRideModel(this._json) : super(id: _json['id'] as String);

  final Map<String, dynamic> _json;

  @override
  Ride toDomain() => RideCompleted(
    id: id,
    driver: _driverFromJson(_json['driver']),
    destinationName: _json['destinationName'] as String,
    arrivedAt: DateTime.parse(_json['arrivedAt'] as String),
    totalCents: _json['totalCents'] as int,
    fareLines: [
      for (final line in _json['fareLines'] as List<dynamic>)
        FareLine(
          label: (line as Map<String, dynamic>)['label'] as String,
          amountCents: line['amountCents'] as int,
        ),
    ],
  );
}

// Shared by every status that carries the driver, the vehicle or a position.

Driver _driverFromJson(Object? json) {
  final driver = json! as Map<String, dynamic>;
  return Driver(
    name: driver['name'] as String,
    rating: (driver['rating'] as num).toDouble(),
    completedRides: driver['completedRides'] as int,
    taxiNumber: driver['taxiNumber'] as String,
    city: driver['city'] as String,
  );
}

Vehicle _vehicleFromJson(Object? json) {
  final vehicle = json! as Map<String, dynamic>;
  return Vehicle(
    model: vehicle['model'] as String,
    color: vehicle['color'] as String,
    plate: vehicle['plate'] as String,
    department: vehicle['department'] as String,
  );
}

Coordinates _coordinatesFromJson(Object? json) {
  final position = json! as Map<String, dynamic>;
  return Coordinates(
    latitude: (position['latitude'] as num).toDouble(),
    longitude: (position['longitude'] as num).toDouble(),
  );
}

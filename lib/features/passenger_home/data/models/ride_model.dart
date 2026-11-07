import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/vehicle.dart';
import 'package:mobile/core/domain/entities/vehicle_color.dart';
import 'package:mobile/features/passenger_home/domain/entities/driver.dart';
import 'package:mobile/features/passenger_home/domain/entities/fare_line.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';

sealed class RideModel {
  const RideModel({required this.id});

  factory RideModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final status = json['status'] as String;
    return switch (status) {
      'SEARCHING_DRIVER' => SearchingDriverRideModel(id: id),
      'NO_DRIVER_FOUND' => NoDriverFoundRideModel(id: id),
      'CANCELLED' => CancelledRideModel(id: id),
      'PASSENGER_NO_SHOW' => PassengerNoShowRideModel(id: id),
      'DRIVER_APPROACHING' => DriverApproachingRideModel(json),
      'DRIVER_ARRIVED' => DriverArrivedRideModel(json),
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

final class CancelledRideModel extends RideModel {
  const CancelledRideModel({required super.id});

  @override
  Ride toDomain() => RideCancelled(id: id);
}

final class PassengerNoShowRideModel extends RideModel {
  const PassengerNoShowRideModel({required super.id});

  @override
  Ride toDomain() => RidePassengerNoShow(id: id);
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

final class DriverArrivedRideModel extends RideModel {
  DriverArrivedRideModel(this._json) : super(id: _json['id'] as String);

  final Map<String, dynamic> _json;

  @override
  Ride toDomain() => RideDriverArrived(
    id: id,
    driver: _driverFromJson(_json['driver']),
    vehicle: _vehicleFromJson(_json['vehicle']),
    driverPosition: _coordinatesFromJson(_json['driverPosition']),
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
    minPriceCents: _json['estimatedPriceMinCents'] as int,
    maxPriceCents: _json['estimatedPriceMaxCents'] as int,
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
    rating: (driver['rating'] as num?)?.toDouble(),
    completedRides: driver['completedRides'] as int,
  );
}

// Absent for a driver registered before the "Votre taxi" step existed.
Vehicle? _vehicleFromJson(Object? json) {
  if (json == null) return null;
  final vehicle = json as Map<String, dynamic>;
  return Vehicle(
    model: vehicle['model'] as String,
    color: VehicleColor.fromApi(vehicle['color'] as String),
    plate: vehicle['plate'] as String,
    adsNumber: vehicle['adsNumber'] as String,
    communeName: vehicle['communeName'] as String,
  );
}

Coordinates _coordinatesFromJson(Object? json) {
  final position = json! as Map<String, dynamic>;
  return Coordinates(
    latitude: (position['latitude'] as num).toDouble(),
    longitude: (position['longitude'] as num).toDouble(),
  );
}

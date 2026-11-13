import 'package:mobile/core/domain/entities/vehicle_color.dart';
import 'package:mobile/features/registration/driver/domain/entities/registration_vehicle.dart';

// The "vehicle" of GET /v1/registration-flows/me, and the body of
// PUT /v1/registration-flows/me/vehicle.
class RegistrationVehicleModel {
  const RegistrationVehicleModel({
    required this.model,
    required this.color,
    required this.plate,
    required this.adsNumber,
    required this.communeCode,
    required this.communeName,
    required this.passengerSeats,
  });

  factory RegistrationVehicleModel.fromJson(Map<String, dynamic> json) =>
      RegistrationVehicleModel(
        model: json['model'] as String,
        color: json['color'] as String,
        plate: json['plate'] as String,
        adsNumber: json['adsNumber'] as String,
        communeCode: json['communeCode'] as String,
        communeName: json['communeName'] as String,
        passengerSeats: json['passengerSeats'] as int,
      );

  factory RegistrationVehicleModel.fromDomain(RegistrationVehicle vehicle) =>
      RegistrationVehicleModel(
        model: vehicle.model,
        color: vehicle.color.apiValue,
        plate: vehicle.plate,
        adsNumber: vehicle.adsNumber,
        communeCode: vehicle.communeCode,
        communeName: vehicle.communeName,
        passengerSeats: vehicle.passengerSeats,
      );

  final String model;
  final String color;
  final String plate;
  final String adsNumber;
  final String communeCode;
  final String communeName;
  final int passengerSeats;

  Map<String, dynamic> toJson() => {
    'model': model,
    'color': color,
    'plate': plate,
    'adsNumber': adsNumber,
    'communeCode': communeCode,
    'communeName': communeName,
    'passengerSeats': passengerSeats,
  };

  RegistrationVehicle toDomain() => RegistrationVehicle(
    model: model,
    color: VehicleColor.fromApi(color),
    plate: plate,
    adsNumber: adsNumber,
    communeCode: communeCode,
    communeName: communeName,
    passengerSeats: passengerSeats,
  );
}

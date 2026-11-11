import 'package:mobile/core/domain/entities/vehicle.dart';
import 'package:mobile/core/domain/entities/vehicle_color.dart';

// "vehicle" of GET /v1/drivers/me/account, e.g. {"model":"Renault Austral",
// "color":"GREY","plate":"AB-123-CD","adsNumber":"118",
// "communeCode":"67482","communeName":"Strasbourg"}.
class DriverVehicleModel {
  const DriverVehicleModel({
    required this.model,
    required this.color,
    required this.plate,
    required this.adsNumber,
    required this.communeName,
  });

  factory DriverVehicleModel.fromJson(Map<String, dynamic> json) =>
      DriverVehicleModel(
        model: json['model'] as String,
        color: json['color'] as String,
        plate: json['plate'] as String,
        adsNumber: json['adsNumber'] as String,
        communeName: json['communeName'] as String,
      );

  final String model;
  final String color;
  final String plate;
  final String adsNumber;
  final String communeName;

  Vehicle toDomain() => Vehicle(
    model: model,
    color: VehicleColor.fromApi(color),
    plate: plate,
    adsNumber: adsNumber,
    communeName: communeName,
  );
}

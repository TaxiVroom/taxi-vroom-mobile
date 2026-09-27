import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/driver_home/domain/entities/demand_overview.dart';
import 'package:mobile/features/driver_home/domain/entities/demand_zone.dart';

class DemandOverviewModel {
  const DemandOverviewModel({
    required this.areaName,
    required this.freeTaxiCount,
    required this.zones,
  });

  factory DemandOverviewModel.fromJson(Map<String, dynamic> json) =>
      DemandOverviewModel(
        areaName: json['areaName'] as String,
        freeTaxiCount: json['freeTaxiCount'] as int,
        zones: (json['zones'] as List<dynamic>)
            .map((e) => DemandZoneModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String areaName;
  final int freeTaxiCount;
  final List<DemandZoneModel> zones;

  DemandOverview toDomain() => DemandOverview(
    areaName: areaName,
    freeTaxiCount: freeTaxiCount,
    zones: zones.map((zone) => zone.toDomain()).toList(),
  );
}

class DemandZoneModel {
  const DemandZoneModel({
    required this.latitude,
    required this.longitude,
    required this.isHigh,
    required this.driveMinutes,
    this.name,
  });

  factory DemandZoneModel.fromJson(Map<String, dynamic> json) =>
      DemandZoneModel(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        isHigh: json['isHigh'] as bool,
        driveMinutes: json['driveMinutes'] as int,
        name: json['name'] as String?,
      );

  final double latitude;
  final double longitude;
  final bool isHigh;
  final int driveMinutes;
  final String? name;

  DemandZone toDomain() => DemandZone(
    center: Coordinates(latitude: latitude, longitude: longitude),
    isHigh: isHigh,
    driveMinutes: driveMinutes,
    name: name,
  );
}

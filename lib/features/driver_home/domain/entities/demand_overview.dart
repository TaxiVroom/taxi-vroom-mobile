import 'package:equatable/equatable.dart';
import 'package:mobile/features/driver_home/domain/entities/demand_zone.dart';

// The demand around the driver: their area and where passengers are.
class DemandOverview extends Equatable {
  const DemandOverview({
    required this.areaName,
    required this.freeTaxiCount,
    required this.zones,
  });

  // E.g. "Centre".
  final String areaName;

  // Other free taxis around the driver.
  final int freeTaxiCount;

  final List<DemandZone> zones;

  // The closest high demand zone, suggested to the driver.
  DemandZone? get closestHighDemand {
    final highZones = zones.where((zone) => zone.isHigh).toList()
      ..sort((a, b) => a.driveMinutes.compareTo(b.driveMinutes));
    return highZones.firstOrNull;
  }

  @override
  List<Object?> get props => [areaName, freeTaxiCount, zones];
}

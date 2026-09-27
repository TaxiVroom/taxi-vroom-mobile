import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/demand_overview.dart';

abstract class DemandRepository {
  Future<Result<DemandOverview>> getDemand({required Coordinates around});
}

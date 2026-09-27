import 'package:mobile/features/driver_home/data/models/demand_overview_model.dart';

// No backend endpoint yet: only the fake implementation exists.
abstract class DemandRemoteDataSource {
  Future<DemandOverviewModel> getDemand({
    required double latitude,
    required double longitude,
  });
}

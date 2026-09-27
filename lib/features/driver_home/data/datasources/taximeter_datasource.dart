import 'package:mobile/features/driver_home/data/models/meter_reading_model.dart';

// Only the simulated meter exists for now; the connected taximeter will come
// later.
abstract class TaximeterDataSource {
  Stream<MeterReadingModel> watchMeter();
}

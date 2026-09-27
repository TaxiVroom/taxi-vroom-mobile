import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/meter_reading.dart';

abstract class TaximeterRepository {
  // The meter of the taxi, live, while the ride is running.
  Stream<Result<MeterReading>> watchMeter();
}

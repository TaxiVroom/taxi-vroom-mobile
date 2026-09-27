import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/meter_reading.dart';
import 'package:mobile/features/driver_home/domain/repositories/taximeter_repository.dart';

// Mirrors the taxi's meter in the app during the ride.
class WatchTaximeterUseCase {
  const WatchTaximeterUseCase(this._taximeterRepository);

  final TaximeterRepository _taximeterRepository;

  Stream<Result<MeterReading>> call() => _taximeterRepository.watchMeter();
}

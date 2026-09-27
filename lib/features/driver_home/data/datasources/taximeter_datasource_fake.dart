import 'package:mobile/features/driver_home/data/datasources/taximeter_datasource.dart';
import 'package:mobile/features/driver_home/data/models/meter_reading_model.dart';

/// Implémentation de développement : un taximètre simulé au tarif A, qui
/// avance au même rythme que le trajet simulé (40 m par seconde).
class TaximeterDataSourceFake implements TaximeterDataSource {
  static const _tick = Duration(seconds: 1);

  // Same national caps as the passenger's fake meter.
  static const _pickupFeeCents = 448;
  static const _pricePerKmCents = 130;
  static const _kmPerTick = 0.04;

  @override
  Stream<MeterReadingModel> watchMeter() async* {
    var distanceKm = 0.0;
    while (true) {
      yield MeterReadingModel.fromJson({
        'tariff': 'A',
        'amountCents': (_pickupFeeCents + _pricePerKmCents * distanceKm)
            .round(),
        'distanceKm': distanceKm,
      });
      await Future<void>.delayed(_tick);
      distanceKm += _kmPerTick;
    }
  }
}

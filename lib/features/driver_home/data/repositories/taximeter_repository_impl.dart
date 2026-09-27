import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/taximeter_datasource.dart';
import 'package:mobile/features/driver_home/domain/entities/meter_reading.dart';
import 'package:mobile/features/driver_home/domain/repositories/taximeter_repository.dart';

class TaximeterRepositoryImpl implements TaximeterRepository {
  const TaximeterRepositoryImpl(this._dataSource);

  final TaximeterDataSource _dataSource;

  @override
  Stream<Result<MeterReading>> watchMeter() =>
      _dataSource.watchMeter().map((model) => Result.ok(model.toDomain()));
}

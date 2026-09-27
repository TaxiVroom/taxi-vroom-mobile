import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/driving_position_datasource.dart';
import 'package:mobile/features/driver_home/domain/repositories/driving_position_repository.dart';

class DrivingPositionRepositoryImpl implements DrivingPositionRepository {
  const DrivingPositionRepositoryImpl(this._dataSource);

  final DrivingPositionDataSource _dataSource;

  @override
  Stream<Result<Coordinates>> watchPosition({
    required List<Coordinates> along,
  }) => _dataSource.watchPosition(along: along).map(Result.ok);
}

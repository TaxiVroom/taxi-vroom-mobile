import 'package:dio/dio.dart';
import 'package:mobile/core/domain/entities/vehicle.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/data/datasources/driver_vehicle_remote_datasource.dart';
import 'package:mobile/features/driver_home/domain/repositories/driver_vehicle_repository.dart';

class DriverVehicleRepositoryImpl implements DriverVehicleRepository {
  const DriverVehicleRepositoryImpl(this._dataSource);

  final DriverVehicleRemoteDataSource _dataSource;

  @override
  Future<Result<Vehicle?>> getVehicle() async {
    try {
      return Result.ok((await _dataSource.getVehicle())?.toDomain());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

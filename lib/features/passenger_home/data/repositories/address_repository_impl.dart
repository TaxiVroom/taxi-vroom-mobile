import 'package:dio/dio.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/data/datasources/address_remote_datasource.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/repositories/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  const AddressRepositoryImpl(this._dataSource);

  final AddressRemoteDataSource _dataSource;

  @override
  Future<Result<Place?>> findPlaceAt(Coordinates point) async {
    try {
      final model = await _dataSource.findAddress(
        latitude: point.latitude,
        longitude: point.longitude,
      );
      return Result.ok(model?.toDomain(point));
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

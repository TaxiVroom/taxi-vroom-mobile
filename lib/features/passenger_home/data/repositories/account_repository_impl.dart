import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/data/datasources/account_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/datasources/saved_place_datasource_fake.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_account.dart';
import 'package:mobile/features/passenger_home/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._dataSource, this._savedPlaceDataSource);

  final AccountRemoteDataSource _dataSource;
  final SavedPlaceDataSource _savedPlaceDataSource;

  @override
  Future<Result<PassengerAccount>> getAccount() async {
    try {
      final model = await _dataSource.getAccount();
      final savedPlaces = await _savedPlaceDataSource.getSavedPlaces();
      return Result.ok(
        model.toDomain([for (final place in savedPlaces) place.toDomain()]),
      );
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

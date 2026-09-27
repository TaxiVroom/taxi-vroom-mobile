import 'package:dio/dio.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/data/datasources/taxi_offer_remote_datasource.dart';
import 'package:mobile/features/passenger_home/domain/entities/coordinates.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_route.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/repositories/taxi_offer_repository.dart';

class TaxiOfferRepositoryImpl implements TaxiOfferRepository {
  const TaxiOfferRepositoryImpl(this._dataSource);

  final TaxiOfferRemoteDataSource _dataSource;

  @override
  Future<Result<List<TaxiOffer>>> getOffers({
    required Coordinates from,
    required Coordinates to,
    required RideRoute route,
  }) async {
    try {
      final models = await _dataSource.getOffers(
        fromLatitude: from.latitude,
        fromLongitude: from.longitude,
        toLatitude: to.latitude,
        toLongitude: to.longitude,
        distanceKm: route.distanceKm,
      );
      return Result.ok(models.map((m) => m.toDomain()).toList());
    } on DioException catch (e) {
      return Result.error(e.toFailure());
    }
  }
}

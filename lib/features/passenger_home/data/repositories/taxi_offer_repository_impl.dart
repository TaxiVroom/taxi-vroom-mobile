import 'package:dio/dio.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/dio_exception_failure.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/data/datasources/taxi_offer_remote_datasource.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/repositories/taxi_offer_repository.dart';

class TaxiOfferRepositoryImpl implements TaxiOfferRepository {
  const TaxiOfferRepositoryImpl(this._dataSource);

  final TaxiOfferRemoteDataSource _dataSource;

  // The server's 400 and 422 codes (see the API's ride.errors.ts).
  static const _refusals = {
    'RIDE.AREA_NOT_SERVED': ValidationFailure(
      "Taxi Vroom n'est pas encore disponible dans votre département.",
    ),
    'RIDE.NO_DRIVER_AVAILABLE': ValidationFailure(
      'Aucun taxi disponible pour le moment.',
    ),
    'RIDE.PICKUP_TIME_NOT_BOOKABLE': ValidationFailure(
      'Cet horaire ne peut plus être réservé, choisissez-en un autre.',
    ),
  };

  @override
  Future<Result<List<TaxiOffer>>> getOffers({
    required Coordinates from,
    required Place to,
    DateTime? scheduledPickup,
  }) async {
    try {
      final models = await _dataSource.getOffers(
        fromLatitude: from.latitude,
        fromLongitude: from.longitude,
        toLatitude: to.coordinates.latitude,
        toLongitude: to.coordinates.longitude,
        destinationName: to.name,
        scheduledPickup: scheduledPickup,
      );
      return Result.ok(models.map((m) => m.toDomain()).toList());
    } on DioException catch (e) {
      return Result.error(_refusal(e) ?? e.toFailure());
    }
  }

  Failure? _refusal(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    if (statusCode != 400 && statusCode != 422) return null;
    final data = response!.data;
    return data is Map<String, dynamic> ? _refusals[data['code']] : null;
  }
}

import 'package:dio/dio.dart';
import 'package:mobile/features/passenger_home/data/models/taxi_offer_model.dart';

abstract class TaxiOfferRemoteDataSource {
  // Each offer is a ride the backend priced from the closest free taxi: its
  // id is what the passenger orders.
  Future<List<TaxiOfferModel>> getOffers({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
    required String destinationName,
  });
}

// The backend owns the pricing: taxi tariffs are set per prefecture. It does
// not know kinds of taxi yet, so its estimate is the plain taxi.
class TaxiOfferRemoteDataSourceImpl implements TaxiOfferRemoteDataSource {
  const TaxiOfferRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TaxiOfferModel>> getOffers({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
    required String destinationName,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/rides',
      data: {
        'originLatitude': fromLatitude,
        'originLongitude': fromLongitude,
        'destinationName': destinationName,
        'destinationLatitude': toLatitude,
        'destinationLongitude': toLongitude,
      },
    );
    final estimate = response.data!;
    return [
      TaxiOfferModel.fromJson({
        ...estimate,
        'id': 'taxi',
        'rideId': estimate['id'],
        'name': 'Taxi',
        'description': '4 places',
        // The passenger does not tell their luggage yet.
        'priceNote': 'hors suppléments',
      }),
    ];
  }
}

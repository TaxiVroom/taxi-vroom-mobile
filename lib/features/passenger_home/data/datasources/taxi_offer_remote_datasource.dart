import 'package:dio/dio.dart';
import 'package:mobile/features/passenger_home/data/models/taxi_offer_model.dart';

abstract class TaxiOfferRemoteDataSource {
  // Each offer is a ride the backend priced from the closest free taxi: its
  // id is what the passenger orders.
  // With scheduledPickup, the ride is priced for that time, to be booked.
  Future<List<TaxiOfferModel>> getOffers({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
    required String destinationName,
    String? fromName,
    DateTime? scheduledPickup,
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
    String? fromName,
    DateTime? scheduledPickup,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/rides',
      data: {
        'originLatitude': fromLatitude,
        'originLongitude': fromLongitude,
        // Without it, the API names the pickup "Position de départ".
        'originName': ?fromName,
        'destinationName': destinationName,
        'destinationLatitude': toLatitude,
        'destinationLongitude': toLongitude,
        if (scheduledPickup != null)
          'pickupAt': scheduledPickup.toUtc().toIso8601String(),
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

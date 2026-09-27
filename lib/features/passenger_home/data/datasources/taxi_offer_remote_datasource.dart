import 'package:mobile/features/passenger_home/data/models/taxi_offer_model.dart';

// No backend endpoint yet: only the fake implementation exists. The backend
// will own the pricing, since taxi tariffs are set per prefecture.
abstract class TaxiOfferRemoteDataSource {
  Future<List<TaxiOfferModel>> getOffers({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
    required double distanceKm,
  });
}

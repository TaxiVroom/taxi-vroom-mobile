import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';

abstract class TaxiOfferRepository {
  Future<Result<List<TaxiOffer>>> getOffers({
    required Coordinates from,
    required Place to,
  });
}

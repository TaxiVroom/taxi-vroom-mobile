import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';

abstract class TaxiOfferRepository {
  Future<Result<List<TaxiOffer>>> getOffers({
    required Coordinates from,
    required Coordinates to,
    required RideRoute route,
  });
}

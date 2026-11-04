import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';

abstract class TaxiOfferRepository {
  // With scheduledPickup, priced for that time, to be booked.
  Future<Result<List<TaxiOffer>>> getOffers({
    required Coordinates from,
    required Place to,
    DateTime? scheduledPickup,
  });
}

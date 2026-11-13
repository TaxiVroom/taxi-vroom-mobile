import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';

abstract class TaxiOfferRepository {
  // With scheduledPickup, priced for that time, to be booked. [fromName] is
  // the pickup's Mapbox address, kept by the ride; none when unknown. Only a
  // taxi with [passengerCount] seats can take the ride, and the price counts
  // the supplement from the fifth passenger.
  Future<Result<List<TaxiOffer>>> getOffers({
    required Coordinates from,
    required Place to,
    required int passengerCount,
    String? fromName,
    DateTime? scheduledPickup,
  });
}

import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/repositories/taxi_offer_repository.dart';

// "Confirmer le point de prise en charge": the offer to order. The price
// depends on the pickup, so a pin moved more than a few meters is priced
// again from there; within them, it is only the map's rounding, and the
// price shown is kept. Spec point-de-prise-en-charge.md.
class OfferFromPickupUseCase {
  const OfferFromPickupUseCase(this._repository);

  final TaxiOfferRepository _repository;

  static const _movedMeters = 10.0;

  Future<Result<TaxiOffer>> call({
    required TaxiOffer shown,
    required Coordinates pricedFrom,
    required Coordinates pickup,
    required Place destination,
    DateTime? scheduledPickup,
  }) async {
    if (pricedFrom.distanceTo(pickup) <= _movedMeters) {
      return Result.ok(shown);
    }
    final priced = await _repository.getOffers(
      from: pickup,
      to: destination,
      scheduledPickup: scheduledPickup,
    );
    return switch (priced) {
      // The same kind of taxi, at its new price.
      Ok(:final value) => switch (_sameKind(value, shown)) {
        final offer? => Result.ok(offer),
        null => const Result.error(
          ServerFailure('Aucun taxi pour ce point de prise en charge.'),
        ),
      },
      Error(:final error) => Result.error(error),
    };
  }

  TaxiOffer? _sameKind(List<TaxiOffer> offers, TaxiOffer shown) =>
      offers.where((offer) => offer.id == shown.id).firstOrNull;
}

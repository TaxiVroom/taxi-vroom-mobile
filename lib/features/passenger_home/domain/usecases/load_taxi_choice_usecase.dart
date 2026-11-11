import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/core/domain/repositories/route_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_choice.dart';
import 'package:mobile/features/passenger_home/domain/repositories/taxi_offer_repository.dart';
import 'package:mobile/features/passenger_home/domain/usecases/find_place_at_usecase.dart';

// Loads the taxi choice: the route first, then the offers priced on it.
class LoadTaxiChoiceUseCase {
  const LoadTaxiChoiceUseCase({
    required RouteRepository routeRepository,
    required TaxiOfferRepository taxiOfferRepository,
    required FindPlaceAtUseCase findPlaceAtUseCase,
  }) : _routeRepository = routeRepository,
       _taxiOfferRepository = taxiOfferRepository,
       _findPlaceAtUseCase = findPlaceAtUseCase;

  final RouteRepository _routeRepository;
  final TaxiOfferRepository _taxiOfferRepository;
  final FindPlaceAtUseCase _findPlaceAtUseCase;

  // With scheduledPickup, the offers are priced for that time, to be booked.
  // The pickup is named with its Mapbox address: the place chosen, or the
  // address found at [from] for "Position actuelle". Spec
  // point-de-prise-en-charge.md, "Tout sur Mapbox".
  Future<Result<TaxiChoice>> call({
    required Coordinates from,
    required Place to,
    Place? pickupPlace,
    DateTime? scheduledPickup,
  }) async {
    final (routeResult, pickup) = await (
      _routeRepository.getRoute(from: from, to: to.coordinates),
      _pickupAt(from, pickupPlace),
    ).wait;
    final RideRoute route;
    switch (routeResult) {
      case Ok(:final value):
        route = value;
      case Error(:final error):
        return Result.error(error);
    }

    return switch (await _taxiOfferRepository.getOffers(
      from: from,
      fromName: FindPlaceAtUseCase.knownAddress(pickup),
      to: to,
      scheduledPickup: scheduledPickup,
    )) {
      Ok(:final value) => Result.ok(TaxiChoice(route: route, offers: value)),
      // No free taxi now never stops a booking for later: the screen stays,
      // without an offer to order. Spec heure-de-prise-en-charge.md.
      Error(error: NoDriverAvailableFailure()) => Result.ok(
        TaxiChoice(route: route, offers: const []),
      ),
      Error(:final error) => Result.error(error),
    };
  }

  Future<Place> _pickupAt(Coordinates from, Place? chosen) async =>
      chosen ?? await _findPlaceAtUseCase(from);
}

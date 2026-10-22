import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/core/domain/repositories/route_repository.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_choice.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/repositories/taxi_offer_repository.dart';

// Loads the taxi choice: the route first, then the offers priced on it.
class LoadTaxiChoiceUseCase {
  const LoadTaxiChoiceUseCase({
    required RouteRepository routeRepository,
    required TaxiOfferRepository taxiOfferRepository,
  }) : _routeRepository = routeRepository,
       _taxiOfferRepository = taxiOfferRepository;

  final RouteRepository _routeRepository;
  final TaxiOfferRepository _taxiOfferRepository;

  Future<Result<TaxiChoice>> call({
    required Coordinates from,
    required Place to,
  }) async {
    final RideRoute route;
    switch (await _routeRepository.getRoute(from: from, to: to.coordinates)) {
      case Ok(:final value):
        route = value;
      case Error(:final error):
        return Result.error(error);
    }

    final List<TaxiOffer> offers;
    switch (await _taxiOfferRepository.getOffers(from: from, to: to)) {
      case Ok(:final value):
        offers = value;
      case Error(:final error):
        return Result.error(error);
    }

    return Result.ok(TaxiChoice(route: route, offers: offers));
  }
}

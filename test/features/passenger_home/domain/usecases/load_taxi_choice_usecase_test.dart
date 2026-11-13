import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/navigation_route.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/core/domain/repositories/route_repository.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_choice.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/repositories/address_repository.dart';
import 'package:mobile/features/passenger_home/domain/repositories/taxi_offer_repository.dart';
import 'package:mobile/features/passenger_home/domain/usecases/find_place_at_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_taxi_choice_usecase.dart';

// The road from the passenger to the destination, always found.
class _FakeRouteRepository implements RouteRepository {
  @override
  Future<Result<RideRoute>> getRoute({
    required Coordinates from,
    required Coordinates to,
    DateTime? arriveBy,
  }) async => const Result.ok(_LoadTaxiChoiceFixtures.route);

  @override
  Future<Result<NavigationRoute>> getNavigationRoute({
    required Coordinates from,
    required Coordinates to,
  }) => throw UnimplementedError();
}

// The API's answer to the estimate; keeps the pickup name it was sent.
class _FakeTaxiOfferRepository implements TaxiOfferRepository {
  _FakeTaxiOfferRepository(this.result);

  final Result<List<TaxiOffer>> result;
  String? sentName;

  @override
  Future<Result<List<TaxiOffer>>> getOffers({
    required Coordinates from,
    required Place to,
    required int passengerCount,
    String? fromName,
    DateTime? scheduledPickup,
  }) async {
    sentName = fromName;
    return result;
  }
}

// Mapbox's address at a point; counts how often it is asked.
class _FakeAddressRepository implements AddressRepository {
  _FakeAddressRepository(this.place);

  final Place? place;
  int lookups = 0;

  @override
  Future<Result<Place?>> findPlaceAt(Coordinates point) async {
    lookups++;
    return Result.ok(place);
  }
}

abstract final class _LoadTaxiChoiceFixtures {
  static const route = RideRoute(distanceKm: 4, durationMinutes: 12, path: []);
}

void main() {
  group('LoadTaxiChoiceUseCase', () {
    const from = Coordinates(latitude: 48.6108, longitude: 7.7368);
    const to = Place(
      name: 'Parlement Européen',
      address: '',
      coordinates: Coordinates(latitude: 48.5993, longitude: 7.7669),
    );
    const street = Place(
      name: '4 Rue de la Magel',
      address: '4 Rue de la Magel, 67000 Strasbourg, France',
      coordinates: from,
    );

    LoadTaxiChoiceUseCase useCaseWith({
      required _FakeTaxiOfferRepository offers,
      _FakeAddressRepository? addresses,
    }) => LoadTaxiChoiceUseCase(
      routeRepository: _FakeRouteRepository(),
      taxiOfferRepository: offers,
      findPlaceAtUseCase: FindPlaceAtUseCase(
        addresses ?? _FakeAddressRepository(null),
      ),
    );

    test(
      'no free taxi now: the road shown, no offer, booking still possible',
      () async {
        // Arrange
        final useCase = useCaseWith(
          offers: _FakeTaxiOfferRepository(
            const Result.error(
              NoDriverAvailableFailure('Aucun taxi libre pour le moment'),
            ),
          ),
        );

        // Act
        final result = await useCase(from: from, to: to, passengerCount: 1);

        // Assert
        expect(
          result,
          isA<Ok<TaxiChoice>>().having(
            (ok) => ok.value,
            'choice',
            const TaxiChoice(route: _LoadTaxiChoiceFixtures.route, offers: []),
          ),
        );
      },
    );

    test('another refusal, e.g. an area not served: the failure', () async {
      // Arrange
      const notServed = ValidationFailure(
        "Taxi Vroom n'est pas encore disponible dans votre département.",
      );
      final useCase = useCaseWith(
        offers: _FakeTaxiOfferRepository(const Result.error(notServed)),
      );

      // Act
      final result = await useCase(from: from, to: to, passengerCount: 1);

      // Assert
      expect(
        result,
        isA<Error<TaxiChoice>>().having((e) => e.error, 'error', notServed),
      );
    });

    test('"Position actuelle": the pickup named with the address found '
        'there', () async {
      // Arrange
      final offers = _FakeTaxiOfferRepository(const Result.ok([]));
      final useCase = useCaseWith(
        offers: offers,
        addresses: _FakeAddressRepository(street),
      );

      // Act
      await useCase(from: from, to: to, passengerCount: 1);

      // Assert
      expect(offers.sentName, '4 Rue de la Magel, 67000 Strasbourg, France');
    });

    test('a pickup chosen: named with its address, no new lookup', () async {
      // Arrange
      final offers = _FakeTaxiOfferRepository(const Result.ok([]));
      final addresses = _FakeAddressRepository(null);
      final useCase = useCaseWith(offers: offers, addresses: addresses);

      // Act
      await useCase(
        from: from,
        pickupPlace: street,
        to: to,
        passengerCount: 1,
      );

      // Assert
      expect(offers.sentName, '4 Rue de la Magel, 67000 Strasbourg, France');
      expect(addresses.lookups, 0);
    });

    test(
      'no address known where the passenger is: priced without a name',
      () async {
        // Arrange
        final offers = _FakeTaxiOfferRepository(const Result.ok([]));
        final useCase = useCaseWith(offers: offers);

        // Act
        await useCase(from: from, to: to, passengerCount: 1);

        // Assert
        expect(offers.sentName, isNull);
      },
    );
  });
}

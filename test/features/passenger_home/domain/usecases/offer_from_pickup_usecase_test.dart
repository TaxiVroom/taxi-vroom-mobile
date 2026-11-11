import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_tariff.dart';
import 'package:mobile/features/passenger_home/domain/repositories/taxi_offer_repository.dart';
import 'package:mobile/features/passenger_home/domain/usecases/find_place_at_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/offer_from_pickup_usecase.dart';

// The backend's estimate: tells where it was asked to price from.
class _FakeTaxiOfferRepository implements TaxiOfferRepository {
  _FakeTaxiOfferRepository(this.result);

  final Result<List<TaxiOffer>> result;
  Coordinates? pricedFrom;
  String? pricedFromName;

  @override
  Future<Result<List<TaxiOffer>>> getOffers({
    required Coordinates from,
    required Place to,
    String? fromName,
    DateTime? scheduledPickup,
  }) async {
    pricedFrom = from;
    pricedFromName = fromName;
    return result;
  }
}

TaxiOffer _offer({required String rideId, required int minPriceCents}) =>
    TaxiOffer(
      id: 'taxi',
      rideId: rideId,
      name: 'Taxi',
      description: '4 places',
      pickupEtaMinutes: 4,
      minPriceCents: minPriceCents,
      maxPriceCents: minPriceCents + 500,
      tariff: TaxiTariff(
        departmentCode: '67',
        validFrom: DateTime(2026, 2),
        decree: 'Arrêté préfectoral du 26 janvier 2026',
        pickupCents: 310,
        kmCentsA: 101,
        kmCentsB: 143,
        kmCentsC: 202,
        kmCentsD: 286,
        hourlyCents: 3780,
        minimumFareCents: 800,
        nightStartMinute: 19 * 60,
        nightEndMinute: 7 * 60,
      ),
    );

void main() {
  group('OfferFromPickupUseCase', () {
    const pricedFrom = Coordinates(latitude: 48.5734, longitude: 7.7521);
    const destination = Place(
      name: 'Gare de Strasbourg',
      address: '67000 Strasbourg',
      coordinates: Coordinates(latitude: 48.5851, longitude: 7.7346),
    );
    final shown = _offer(rideId: 'shown-ride', minPriceCents: 2000);

    test('the pin stayed within a few meters: the price shown', () async {
      // Arrange: about 3 m north, the map's own rounding
      final repository = _FakeTaxiOfferRepository(const Result.ok([]));
      final useCase = OfferFromPickupUseCase(repository);
      const pickup = Place(
        name: '2 Rue du Dôme',
        address: '2 Rue du Dôme, 67000 Strasbourg, France',
        coordinates: Coordinates(latitude: 48.57343, longitude: 7.7521),
      );

      // Act
      final result = await useCase(
        shown: shown,
        pricedFrom: pricedFrom,
        pickup: pickup,
        destination: destination,
      );

      // Assert
      expect((result as Ok<TaxiOffer>).value, shown);
      expect(repository.pricedFrom, isNull);
    });

    test('the pin moved: priced again from the new pickup, named with its '
        'Mapbox address', () async {
      // Arrange: about 200 m north
      final moved = _offer(rideId: 'moved-ride', minPriceCents: 2300);
      final repository = _FakeTaxiOfferRepository(Result.ok([moved]));
      final useCase = OfferFromPickupUseCase(repository);
      const pickup = Place(
        name: '20 Rue du Dôme',
        address: '20 Rue du Dôme, 67000 Strasbourg, France',
        coordinates: Coordinates(latitude: 48.5752, longitude: 7.7521),
      );

      // Act
      final result = await useCase(
        shown: shown,
        pricedFrom: pricedFrom,
        pickup: pickup,
        destination: destination,
      );

      // Assert
      expect((result as Ok<TaxiOffer>).value, moved);
      expect(repository.pricedFrom, pickup.coordinates);
      expect(
        repository.pricedFromName,
        '20 Rue du Dôme, 67000 Strasbourg, France',
      );
    });

    test(
      'the pin moved where no address is known: priced without a name',
      () async {
        // Arrange: about 200 m north, "Adresse inconnue" under the pin
        final moved = _offer(rideId: 'moved-ride', minPriceCents: 2300);
        final repository = _FakeTaxiOfferRepository(Result.ok([moved]));
        final useCase = OfferFromPickupUseCase(repository);
        final pickup = FindPlaceAtUseCase.unknownPlaceAt(
          const Coordinates(latitude: 48.5752, longitude: 7.7521),
        );

        // Act
        await useCase(
          shown: shown,
          pricedFrom: pricedFrom,
          pickup: pickup,
          destination: destination,
        );

        // Assert
        expect(repository.pricedFromName, isNull);
      },
    );

    test('the new estimate fails: the failure, nothing ordered', () async {
      // Arrange
      const failure = ServerFailure('Zone non desservie');
      final repository = _FakeTaxiOfferRepository(
        const Result.error(failure),
      );
      final useCase = OfferFromPickupUseCase(repository);
      const pickup = Place(
        name: '20 Rue du Dôme',
        address: '20 Rue du Dôme, 67000 Strasbourg, France',
        coordinates: Coordinates(latitude: 48.5752, longitude: 7.7521),
      );

      // Act
      final result = await useCase(
        shown: shown,
        pricedFrom: pricedFrom,
        pickup: pickup,
        destination: destination,
      );

      // Assert
      expect((result as Error<TaxiOffer>).error, failure);
    });
  });
}

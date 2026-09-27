import 'package:mobile/features/passenger_home/data/datasources/taxi_offer_remote_datasource.dart';
import 'package:mobile/features/passenger_home/data/models/taxi_offer_model.dart';

/// Implémentation de développement avec données de test.
/// Prix fictifs à partir des plafonds de la maquette (4,48 € de prise en
/// charge, 1,30 €/km, 8 € minimum), avec une fourchette de ±10 %.
class TaxiOfferRemoteDataSourceFake implements TaxiOfferRemoteDataSource {
  static const _pickupFeeCents = 448;
  static const _pricePerKmCents = 130;
  static const _minimumFareCents = 800;

  @override
  Future<List<TaxiOfferModel>> getOffers({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
    required double distanceKm,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final fareCents = _pickupFeeCents + (_pricePerKmCents * distanceKm).round();
    final minPriceCents = _roundDownToEuro((fareCents * 0.9).round());
    final maxPriceCents = _roundUpToEuro((fareCents * 1.1).round());
    final priceRange = {
      'minPriceCents': minPriceCents < _minimumFareCents
          ? _minimumFareCents
          : minPriceCents,
      'maxPriceCents': maxPriceCents < _minimumFareCents
          ? _minimumFareCents
          : maxPriceCents,
    };

    return [
      {
        'id': 'taxi',
        'name': 'Taxi',
        'description': '4 places',
        'pickupEtaMinutes': 4,
        ...priceRange,
      },
      {
        'id': 'taxi-van',
        'name': 'Taxi Van',
        'description': "Jusqu'à 7 places",
        'pickupEtaMinutes': 9,
        ...priceRange,
        'priceNote': '+4 € dès le 5e passager',
      },
      {
        'id': 'taxi-access',
        'name': 'Taxi Accès',
        'description': 'Fauteuil roulant',
        'pickupEtaMinutes': 14,
        ...priceRange,
        'priceNote': 'sans supplément',
      },
    ].map(TaxiOfferModel.fromJson).toList();
  }

  static int _roundDownToEuro(int cents) => cents - cents % 100;

  static int _roundUpToEuro(int cents) =>
      cents % 100 == 0 ? cents : cents - cents % 100 + 100;
}

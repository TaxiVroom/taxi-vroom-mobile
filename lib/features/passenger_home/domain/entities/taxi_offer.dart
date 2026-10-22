import 'package:equatable/equatable.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_tariff.dart';

// A kind of taxi the passenger can order, with its estimated price range.
// A taxi always runs on its meter: the real price is only known on arrival.
class TaxiOffer extends Equatable {
  const TaxiOffer({
    required this.id,
    required this.rideId,
    required this.name,
    required this.description,
    required this.pickupEtaMinutes,
    required this.minPriceCents,
    required this.maxPriceCents,
    required this.tariff,
    this.priceNote,
  });

  final String id;

  // The ride the backend created with this price: ordering it keeps the
  // price shown.
  final String rideId;
  final String name;
  final String description;
  final int pickupEtaMinutes;
  final int minPriceCents;
  final int maxPriceCents;
  final TaxiTariff tariff;

  // E.g. a supplement rule, shown under the price.
  final String? priceNote;

  @override
  List<Object?> get props => [
    id,
    rideId,
    name,
    description,
    pickupEtaMinutes,
    minPriceCents,
    maxPriceCents,
    tariff,
    priceNote,
  ];
}

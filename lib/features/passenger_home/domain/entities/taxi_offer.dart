import 'package:equatable/equatable.dart';

// A kind of taxi the passenger can order, with its estimated price range.
// A taxi always runs on its meter: the real price is only known on arrival.
class TaxiOffer extends Equatable {
  const TaxiOffer({
    required this.id,
    required this.name,
    required this.description,
    required this.pickupEtaMinutes,
    required this.minPriceCents,
    required this.maxPriceCents,
    this.priceNote,
  });

  final String id;
  final String name;
  final String description;
  final int pickupEtaMinutes;
  final int minPriceCents;
  final int maxPriceCents;

  // E.g. a supplement rule, shown under the price.
  final String? priceNote;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    pickupEtaMinutes,
    minPriceCents,
    maxPriceCents,
    priceNote,
  ];
}

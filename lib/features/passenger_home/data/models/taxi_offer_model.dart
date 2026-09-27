import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';

class TaxiOfferModel {
  const TaxiOfferModel({
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
  final String? priceNote;

  factory TaxiOfferModel.fromJson(Map<String, dynamic> json) => TaxiOfferModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    pickupEtaMinutes: json['pickupEtaMinutes'] as int,
    minPriceCents: json['minPriceCents'] as int,
    maxPriceCents: json['maxPriceCents'] as int,
    priceNote: json['priceNote'] as String?,
  );

  TaxiOffer toDomain() => TaxiOffer(
    id: id,
    name: name,
    description: description,
    pickupEtaMinutes: pickupEtaMinutes,
    minPriceCents: minPriceCents,
    maxPriceCents: maxPriceCents,
    priceNote: priceNote,
  );
}

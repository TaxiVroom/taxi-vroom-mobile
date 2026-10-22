import 'package:mobile/features/passenger_home/data/models/taxi_tariff_model.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';

class TaxiOfferModel {
  const TaxiOfferModel({
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

  factory TaxiOfferModel.fromJson(Map<String, dynamic> json) => TaxiOfferModel(
    id: json['id'] as String,
    rideId: json['rideId'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    pickupEtaMinutes: json['pickupEtaMinutes'] as int,
    minPriceCents: json['minPriceCents'] as int,
    maxPriceCents: json['maxPriceCents'] as int,
    tariff: TaxiTariffModel.fromJson(json['tariff'] as Map<String, dynamic>),
    priceNote: json['priceNote'] as String?,
  );

  final String id;
  final String rideId;
  final String name;
  final String description;
  final int pickupEtaMinutes;
  final int minPriceCents;
  final int maxPriceCents;
  final TaxiTariffModel tariff;
  final String? priceNote;

  TaxiOffer toDomain() => TaxiOffer(
    id: id,
    rideId: rideId,
    name: name,
    description: description,
    pickupEtaMinutes: pickupEtaMinutes,
    minPriceCents: minPriceCents,
    maxPriceCents: maxPriceCents,
    tariff: tariff.toDomain(),
    priceNote: priceNote,
  );
}

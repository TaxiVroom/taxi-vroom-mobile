import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/features/passenger_home/domain/entities/taxi_offer.dart';

// Everything the taxi choice screen shows.
class TaxiChoice extends Equatable {
  const TaxiChoice({required this.route, required this.offers});

  final RideRoute route;
  final List<TaxiOffer> offers;

  // The offer the passenger picked, if it is still among the offers.
  TaxiOffer? offerById(String? id) =>
      offers.where((offer) => offer.id == id).firstOrNull;

  // Right now, the taxi first drives to the passenger, then to the
  // destination. Booked in advance, the ride starts at the pickup time.
  DateTime estimatedArrival({
    required TaxiOffer offer,
    required DateTime now,
    DateTime? scheduledPickup,
  }) {
    final rideDuration = Duration(minutes: route.durationMinutes);
    if (scheduledPickup != null) return scheduledPickup.add(rideDuration);
    return now.add(Duration(minutes: offer.pickupEtaMinutes) + rideDuration);
  }

  @override
  List<Object?> get props => [route, offers];
}

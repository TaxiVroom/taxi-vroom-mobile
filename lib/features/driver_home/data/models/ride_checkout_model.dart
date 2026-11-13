import 'package:mobile/features/driver_home/domain/entities/fare_supplement.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';

// The supplements allowed for a ride, from the server. With the ride's
// passengers and the tariff's price for each one beyond the fourth (from
// GET /v1/rides/:rideId/checkout), the "5e passager et plus" line is added.
class RideCheckoutModel {
  const RideCheckoutModel({
    required this.supplements,
    this.passengerCount,
    this.extraPassengerCents,
  });

  factory RideCheckoutModel.fromJson(Map<String, dynamic> json) =>
      RideCheckoutModel(
        supplements: [
          for (final supplement in json['supplements'] as List<dynamic>)
            (
              id: (supplement as Map<String, dynamic>)['id'] as String,
              label: supplement['label'] as String,
              amountCents: supplement['amountCents'] as int,
            ),
        ],
        passengerCount: json['passengerCount'] as int?,
        extraPassengerCents: json['extraPassengerCents'] as int?,
      );

  final List<({String id, String label, int amountCents})> supplements;

  // Null for a checkout that lists its own passenger line, as the fake does.
  final int? passengerCount;
  final int? extraPassengerCents;

  // The meter amount is typed by the driver afterwards.
  RideCheckout toDomain() {
    final passengerCount = this.passengerCount;
    final extraPassengerCents = this.extraPassengerCents;
    return RideCheckout(
      supplements: [
        for (final supplement in supplements)
          FareSupplement(
            id: supplement.id,
            label: supplement.label,
            amountCents: supplement.amountCents,
          ),
        if (passengerCount != null && extraPassengerCents != null)
          ?FareSupplement.beyondFourthPassenger(
            passengerCount: passengerCount,
            unitCents: extraPassengerCents,
          ),
      ],
    );
  }
}

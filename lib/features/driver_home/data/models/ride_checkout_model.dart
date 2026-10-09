import 'package:mobile/features/driver_home/domain/entities/fare_supplement.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';

// The supplements allowed for a ride, from the server.
class RideCheckoutModel {
  const RideCheckoutModel({required this.supplements});

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
      );

  final List<({String id, String label, int amountCents})> supplements;

  // The meter amount is typed by the driver afterwards.
  RideCheckout toDomain() => RideCheckout(
    supplements: [
      for (final supplement in supplements)
        FareSupplement(
          id: supplement.id,
          label: supplement.label,
          amountCents: supplement.amountCents,
        ),
    ],
  );
}

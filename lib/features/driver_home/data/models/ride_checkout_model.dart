import 'package:mobile/features/driver_home/domain/entities/fare_supplement.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_checkout.dart';

// The supplements allowed and the payment of a ride, from the server.
class RideCheckoutModel {
  const RideCheckoutModel({
    required this.supplements,
    required this.paidInApp,
    required this.paymentLabel,
  });

  factory RideCheckoutModel.fromJson(Map<String, dynamic> json) {
    final payment = json['payment'] as Map<String, dynamic>;
    return RideCheckoutModel(
      supplements: [
        for (final supplement in json['supplements'] as List<dynamic>)
          (
            id: (supplement as Map<String, dynamic>)['id'] as String,
            label: supplement['label'] as String,
            amountCents: supplement['amountCents'] as int,
          ),
      ],
      paidInApp: payment['paidInApp'] as bool,
      paymentLabel: payment['label'] as String,
    );
  }

  final List<({String id, String label, int amountCents})> supplements;
  final bool paidInApp;
  final String paymentLabel;

  RideCheckout toDomain({required int meterCents}) => RideCheckout(
    meterCents: meterCents,
    supplements: [
      for (final supplement in supplements)
        FareSupplement(
          id: supplement.id,
          label: supplement.label,
          amountCents: supplement.amountCents,
        ),
    ],
    paidInApp: paidInApp,
    paymentLabel: paymentLabel,
  );
}

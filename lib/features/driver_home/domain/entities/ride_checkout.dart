import 'package:equatable/equatable.dart';
import 'package:mobile/features/driver_home/domain/entities/fare_supplement.dart';

// The end of a ride: the meter amount confirmed by the driver, plus the
// supplements, and how the passenger pays.
class RideCheckout extends Equatable {
  const RideCheckout({
    required this.meterCents,
    required this.supplements,
    required this.paidInApp,
    required this.paymentLabel,
    this.supplementCounts = const {},
  });

  // Read from the taximeter, corrected by the driver if needed: the meter is
  // the legal price.
  final int meterCents;

  // The supplements the city allows.
  final List<FareSupplement> supplements;

  // How many of each supplement, by id. Missing means 0.
  final Map<String, int> supplementCounts;

  // True: nothing to collect in the taxi.
  final bool paidInApp;

  // E.g. "Visa de Camille".
  final String paymentLabel;

  int countOf(FareSupplement supplement) =>
      supplementCounts[supplement.id] ?? 0;

  int get totalCents => supplements.fold(
    meterCents,
    (total, supplement) => total + supplement.amountCents * countOf(supplement),
  );

  RideCheckout withMeterCents(int meterCents) => RideCheckout(
    meterCents: meterCents,
    supplements: supplements,
    supplementCounts: supplementCounts,
    paidInApp: paidInApp,
    paymentLabel: paymentLabel,
  );

  // Never below 0.
  RideCheckout withCount(FareSupplement supplement, int count) => RideCheckout(
    meterCents: meterCents,
    supplements: supplements,
    supplementCounts: {
      ...supplementCounts,
      supplement.id: count < 0 ? 0 : count,
    },
    paidInApp: paidInApp,
    paymentLabel: paymentLabel,
  );

  @override
  List<Object?> get props => [
    meterCents,
    supplements,
    supplementCounts,
    paidInApp,
    paymentLabel,
  ];
}

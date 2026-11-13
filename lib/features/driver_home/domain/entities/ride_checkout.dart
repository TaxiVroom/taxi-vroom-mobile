import 'package:equatable/equatable.dart';
import 'package:mobile/features/driver_home/domain/entities/fare_supplement.dart';

// The end of a ride: the meter amount typed by the driver, plus the
// supplements. The passenger pays on board, by card or cash.
class RideCheckout extends Equatable {
  const RideCheckout({
    required this.supplements,
    this.meterCents,
    this.supplementCounts = const {},
  });

  // Copied by the driver from the taxi's meter, the legal price: the app
  // cannot read the meter. Null until typed.
  final int? meterCents;

  // The supplements the city allows.
  final List<FareSupplement> supplements;

  // How many of each supplement, by id, once the driver changed it. Missing
  // means the supplement's initial count.
  final Map<String, int> supplementCounts;

  int countOf(FareSupplement supplement) =>
      supplementCounts[supplement.id] ?? supplement.initialCount;

  // False once the supplement's maximum is reached: the "+" is off.
  bool canAdd(FareSupplement supplement) {
    final max = supplement.maxCount;
    return max == null || countOf(supplement) < max;
  }

  // The supplements added at least once, with their count.
  List<(FareSupplement, int)> get addedSupplements => [
    for (final supplement in supplements)
      if (countOf(supplement) > 0) (supplement, countOf(supplement)),
  ];

  // Null until the meter amount is typed.
  int? get totalCents {
    final meterCents = this.meterCents;
    if (meterCents == null) return null;
    return supplements.fold<int>(
      meterCents,
      (total, supplement) =>
          total + supplement.amountCents * countOf(supplement),
    );
  }

  RideCheckout withMeterCents(int? meterCents) => RideCheckout(
    meterCents: meterCents,
    supplements: supplements,
    supplementCounts: supplementCounts,
  );

  // Never below 0, nor above the supplement's maximum.
  RideCheckout withCount(FareSupplement supplement, int count) => RideCheckout(
    meterCents: meterCents,
    supplements: supplements,
    supplementCounts: {
      ...supplementCounts,
      supplement.id: _bounded(supplement, count),
    },
  );

  int _bounded(FareSupplement supplement, int count) {
    final capped = switch (supplement.maxCount) {
      final max? when count > max => max,
      _ => count,
    };
    return capped < 0 ? 0 : capped;
  }

  @override
  List<Object?> get props => [meterCents, supplements, supplementCounts];
}

import 'package:equatable/equatable.dart';

// A regulated extra the driver adds at the end of a ride, e.g. a bulky bag.
// Its amount depends on the city's fare rules.
class FareSupplement extends Equatable {
  const FareSupplement({
    required this.id,
    required this.label,
    required this.amountCents,
    this.maxCount,
    this.initialCount = 0,
  });

  // The "5e passager et plus" line of a ride: one unit for each passenger
  // beyond the fourth, all of them to start, and no more than them. Null up to
  // four passengers: nothing more to charge. The id is the one the API checks.
  // Spec taxi-vroom-api/docs/specs/nombre-de-passagers.md, situation 6.
  static FareSupplement? beyondFourthPassenger({
    required int passengerCount,
    required int unitCents,
  }) {
    const passengersWithoutSupplement = 4;
    final beyondFourth = passengerCount - passengersWithoutSupplement;
    if (beyondFourth <= 0) return null;
    return FareSupplement(
      id: 'fifth-passenger',
      label: '5e passager et plus',
      amountCents: unitCents,
      maxCount: beyondFourth,
      initialCount: beyondFourth,
    );
  }

  final String id;

  // E.g. "5e passager et plus".
  final String label;

  // For one unit.
  final int amountCents;

  // The most the driver can add, e.g. the passengers of the ride beyond the
  // fourth; null for no limit.
  final int? maxCount;

  // How many the line holds before the driver touches it, e.g. the passengers
  // beyond the fourth, which the driver may lower. Spec
  // taxi-vroom-api/docs/specs/nombre-de-passagers.md.
  final int initialCount;

  @override
  List<Object?> get props => [id, label, amountCents, maxCount, initialCount];
}

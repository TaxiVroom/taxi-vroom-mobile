import 'package:equatable/equatable.dart';

// A regulated extra the driver adds at the end of a ride, e.g. a bulky bag.
// Its amount depends on the city's fare rules.
class FareSupplement extends Equatable {
  const FareSupplement({
    required this.id,
    required this.label,
    required this.amountCents,
  });

  final String id;

  // E.g. "Bagage encombrant".
  final String label;

  // For one unit.
  final int amountCents;

  @override
  List<Object?> get props => [id, label, amountCents];
}

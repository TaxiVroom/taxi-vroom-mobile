import 'package:equatable/equatable.dart';

// One line of the meter's breakdown, e.g. "Prise en charge 4,48 €".
class FareLine extends Equatable {
  const FareLine({required this.label, required this.amountCents});

  final String label;
  final int amountCents;

  @override
  List<Object?> get props => [label, amountCents];
}

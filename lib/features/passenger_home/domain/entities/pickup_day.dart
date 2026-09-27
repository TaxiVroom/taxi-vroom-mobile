import 'package:equatable/equatable.dart';

// A day the passenger can book a taxi for, with its pickup time slots.
class PickupDay extends Equatable {
  const PickupDay({required this.date, required this.slots});

  // Midnight of that day.
  final DateTime date;
  final List<DateTime> slots;

  @override
  List<Object?> get props => [date, slots];
}

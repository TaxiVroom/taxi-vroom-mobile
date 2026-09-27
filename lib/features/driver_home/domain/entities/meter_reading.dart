import 'package:equatable/equatable.dart';

// What the taxi's meter shows: it is the legal price, the app only mirrors it.
class MeterReading extends Equatable {
  const MeterReading({
    required this.tariff,
    required this.amountCents,
    required this.distanceKm,
  });

  // Regulated tariff applied (A, B, C or D).
  final String tariff;

  final int amountCents;

  // Driven since the ride started.
  final double distanceKm;

  @override
  List<Object?> get props => [tariff, amountCents, distanceKm];
}

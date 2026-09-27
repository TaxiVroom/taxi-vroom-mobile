import 'package:equatable/equatable.dart';

// A finished ride, as listed in the history.
class PastRide extends Equatable {
  const PastRide({
    required this.id,
    required this.originName,
    required this.destinationName,
    required this.startedAt,
    required this.tariff,
    required this.totalCents,
  });

  final String id;
  final String originName;
  final String destinationName;
  final DateTime startedAt;
  final String tariff;
  final int totalCents;

  @override
  List<Object?> get props => [
    id,
    originName,
    destinationName,
    startedAt,
    tariff,
    totalCents,
  ];
}

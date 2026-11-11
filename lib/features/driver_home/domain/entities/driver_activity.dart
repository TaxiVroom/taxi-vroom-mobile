import 'package:equatable/equatable.dart';

// The driver's figures on the "Conduire" tab: the pill and the three cards.
// Spec taxi-vroom-api/docs/specs/gains-reels.md.
class DriverActivity extends Equatable {
  const DriverActivity({
    required this.todayEarningsCents,
    required this.weekRideCount,
    required this.averageRating,
    required this.acceptanceRatePercent,
  });

  final int todayEarningsCents;

  // Completed since Monday.
  final int weekRideCount;

  // Null without any rating yet.
  final double? averageRating;

  // The share of the last 100 ride requests accepted; null under 10
  // requests.
  final int? acceptanceRatePercent;

  @override
  List<Object?> get props => [
    todayEarningsCents,
    weekRideCount,
    averageRating,
    acceptanceRatePercent,
  ];
}

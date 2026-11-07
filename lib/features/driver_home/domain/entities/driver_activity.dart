import 'package:equatable/equatable.dart';

// The driver's availability and their recent figures.
class DriverActivity extends Equatable {
  const DriverActivity({
    required this.isOnline,
    required this.todayEarningsCents,
    required this.weekRideCount,
    required this.averageRating,
    required this.acceptanceRatePercent,
  });

  // Online: the taxi light is green and ride requests can come in.
  final bool isOnline;

  final int todayEarningsCents;
  final int weekRideCount;
  final double averageRating;
  final int acceptanceRatePercent;

  DriverActivity withOnline({required bool isOnline}) => DriverActivity(
    isOnline: isOnline,
    todayEarningsCents: todayEarningsCents,
    weekRideCount: weekRideCount,
    averageRating: averageRating,
    acceptanceRatePercent: acceptanceRatePercent,
  );

  @override
  List<Object?> get props => [
    isOnline,
    todayEarningsCents,
    weekRideCount,
    averageRating,
    acceptanceRatePercent,
  ];
}

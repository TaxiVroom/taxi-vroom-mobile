import 'package:equatable/equatable.dart';

// The driver's availability and their recent figures.
class DriverActivity extends Equatable {
  const DriverActivity({
    required this.isOnline,
    required this.receivesBookings,
    required this.todayEarningsCents,
    required this.weekRideCount,
    required this.averageRating,
    required this.acceptanceRatePercent,
  });

  // Online: the taxi light is green and ride requests can come in.
  final bool isOnline;

  // Also offered rides booked in advance in the driver's area.
  final bool receivesBookings;

  final int todayEarningsCents;
  final int weekRideCount;
  final double averageRating;
  final int acceptanceRatePercent;

  DriverActivity withOnline({required bool isOnline}) => DriverActivity(
    isOnline: isOnline,
    receivesBookings: receivesBookings,
    todayEarningsCents: todayEarningsCents,
    weekRideCount: weekRideCount,
    averageRating: averageRating,
    acceptanceRatePercent: acceptanceRatePercent,
  );

  DriverActivity withReceivesBookings({required bool receivesBookings}) =>
      DriverActivity(
        isOnline: isOnline,
        receivesBookings: receivesBookings,
        todayEarningsCents: todayEarningsCents,
        weekRideCount: weekRideCount,
        averageRating: averageRating,
        acceptanceRatePercent: acceptanceRatePercent,
      );

  @override
  List<Object?> get props => [
    isOnline,
    receivesBookings,
    todayEarningsCents,
    weekRideCount,
    averageRating,
    acceptanceRatePercent,
  ];
}

import 'package:mobile/features/driver_home/domain/entities/driver_activity.dart';

class DriverActivityModel {
  const DriverActivityModel({
    required this.isOnline,
    required this.receivesBookings,
    required this.todayEarningsCents,
    required this.weekRideCount,
    required this.averageRating,
    required this.acceptanceRatePercent,
  });

  factory DriverActivityModel.fromJson(Map<String, dynamic> json) =>
      DriverActivityModel(
        isOnline: json['isOnline'] as bool,
        receivesBookings: json['receivesBookings'] as bool,
        todayEarningsCents: json['todayEarningsCents'] as int,
        weekRideCount: json['weekRideCount'] as int,
        averageRating: (json['averageRating'] as num).toDouble(),
        acceptanceRatePercent: json['acceptanceRatePercent'] as int,
      );

  final bool isOnline;
  final bool receivesBookings;
  final int todayEarningsCents;
  final int weekRideCount;
  final double averageRating;
  final int acceptanceRatePercent;

  DriverActivity toDomain() => DriverActivity(
    isOnline: isOnline,
    receivesBookings: receivesBookings,
    todayEarningsCents: todayEarningsCents,
    weekRideCount: weekRideCount,
    averageRating: averageRating,
    acceptanceRatePercent: acceptanceRatePercent,
  );
}

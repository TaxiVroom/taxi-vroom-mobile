import 'package:mobile/features/driver_home/domain/entities/driver_activity.dart';

class DriverActivityModel {
  const DriverActivityModel({
    required this.todayEarningsCents,
    required this.weekRideCount,
    required this.averageRating,
    required this.acceptanceRatePercent,
  });

  factory DriverActivityModel.fromJson(Map<String, dynamic> json) =>
      DriverActivityModel(
        todayEarningsCents: json['todayEarningsCents'] as int,
        weekRideCount: json['weekRideCount'] as int,
        averageRating: (json['averageRating'] as num?)?.toDouble(),
        acceptanceRatePercent: json['acceptanceRatePercent'] as int?,
      );

  final int todayEarningsCents;
  final int weekRideCount;
  final double? averageRating;
  final int? acceptanceRatePercent;

  DriverActivity toDomain() => DriverActivity(
    todayEarningsCents: todayEarningsCents,
    weekRideCount: weekRideCount,
    averageRating: averageRating,
    acceptanceRatePercent: acceptanceRatePercent,
  );
}

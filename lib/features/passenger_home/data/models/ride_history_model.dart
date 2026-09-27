import 'package:mobile/features/passenger_home/data/models/booked_ride_model.dart';
import 'package:mobile/features/passenger_home/data/models/past_ride_model.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_history.dart';

class RideHistoryModel {
  const RideHistoryModel({required this.upcoming, required this.past});

  final List<BookedRideModel> upcoming;
  final List<PastRideModel> past;

  factory RideHistoryModel.fromJson(Map<String, dynamic> json) =>
      RideHistoryModel(
        upcoming: [
          for (final ride in json['upcoming'] as List<dynamic>)
            BookedRideModel.fromJson(ride as Map<String, dynamic>),
        ],
        past: [
          for (final ride in json['past'] as List<dynamic>)
            PastRideModel.fromJson(ride as Map<String, dynamic>),
        ],
      );

  RideHistory toDomain() => RideHistory(
    upcoming: upcoming.map((ride) => ride.toDomain()).toList(),
    past: past.map((ride) => ride.toDomain()).toList(),
  );
}

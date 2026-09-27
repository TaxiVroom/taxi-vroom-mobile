import 'package:mobile/features/passenger_home/domain/entities/recent_destination.dart';

class RecentDestinationModel {
  const RecentDestinationModel({
    required this.name,
    required this.address,
    required this.distanceKm,
  });

  final String name;
  final String address;
  final double distanceKm;

  factory RecentDestinationModel.fromJson(Map<String, dynamic> json) =>
      RecentDestinationModel(
        name: json['name'] as String,
        address: json['address'] as String,
        distanceKm: (json['distanceKm'] as num).toDouble(),
      );

  RecentDestination toDomain() => RecentDestination(
    name: name,
    address: address,
    distanceKm: distanceKm,
  );
}

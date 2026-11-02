import 'package:mobile/features/driver_home/data/models/driver_ride_model.dart';
import 'package:mobile/features/driver_home/domain/entities/current_driver_ride.dart';

class CurrentDriverRideModel {
  const CurrentDriverRideModel({
    required this.status,
    required this.arrivedAt,
    required this.ride,
  });

  factory CurrentDriverRideModel.fromJson(
    Map<String, dynamic> json, {
    required DriverRideModel ride,
  }) {
    final arrivedAt = json['arrivedAt'] as String?;
    return CurrentDriverRideModel(
      status: json['status'] as String,
      arrivedAt: arrivedAt == null ? null : DateTime.parse(arrivedAt),
      ride: ride,
    );
  }

  final String status;
  final DateTime? arrivedAt;
  final DriverRideModel ride;

  // Null when the status is not a step the driver comes back to.
  CurrentDriverRide? toDomain() {
    final driverRide = ride.toDomain();
    final arrivedAt = this.arrivedAt;
    return switch (DriverRideStep.fromStatus(status)) {
      DriverRideStep.pickup => CurrentRideAtPickup(ride: driverRide),
      DriverRideStep.boarding when arrivedAt != null => CurrentRideAtBoarding(
        ride: driverRide,
        arrivedAt: arrivedAt,
      ),
      DriverRideStep.inRide => CurrentRideInProgress(ride: driverRide),
      _ => null,
    };
  }
}

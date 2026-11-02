import 'package:equatable/equatable.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';

// The screen to come back to when the app starts during a ride.
enum DriverRideStep {
  pickup,
  boarding,
  inRide;

  // Null when the status is not a step of the driver's ride.
  static DriverRideStep? fromStatus(String status) => switch (status) {
    'DRIVER_EN_ROUTE' => pickup,
    'DRIVER_ARRIVED' => boarding,
    'IN_PROGRESS' => inRide,
    _ => null,
  };
}

// The ride the driver had when the app was closed.
sealed class CurrentDriverRide extends Equatable {
  const CurrentDriverRide({required this.ride});

  final DriverRide ride;

  @override
  List<Object?> get props => [ride];
}

final class CurrentRideAtPickup extends CurrentDriverRide {
  const CurrentRideAtPickup({required super.ride});
}

final class CurrentRideAtBoarding extends CurrentDriverRide {
  const CurrentRideAtBoarding({required super.ride, required this.arrivedAt});

  final DateTime arrivedAt;

  @override
  List<Object?> get props => [ride, arrivedAt];
}

final class CurrentRideInProgress extends CurrentDriverRide {
  const CurrentRideInProgress({required super.ride});
}

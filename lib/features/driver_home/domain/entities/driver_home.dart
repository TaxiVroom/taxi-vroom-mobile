import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_activity.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';

// Everything the driver home screen shows, offline and online.
class DriverHome extends Equatable {
  const DriverHome({
    required this.position,
    required this.activity,
    this.nextBooking,
  });

  final Coordinates position;
  final DriverActivity activity;

  // The next accepted booking, if any.
  final DriverBooking? nextBooking;

  DriverHome withActivity(DriverActivity activity) => DriverHome(
    position: position,
    activity: activity,
    nextBooking: nextBooking,
  );

  @override
  List<Object?> get props => [position, activity, nextBooking];
}

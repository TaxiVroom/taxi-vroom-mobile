import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';

// Everything the driver home screen shows, offline and online. Its figures
// load apart: DriverActivity.
class DriverHome extends Equatable {
  const DriverHome({
    required this.position,
    this.isOnline = false,
    this.nextBooking,
  });

  final Coordinates position;

  // Online: the taxi light is green and ride requests can come in. The app
  // always starts offline: only this phone knows it, not the API.
  final bool isOnline;

  // The next accepted booking, if any.
  final DriverBooking? nextBooking;

  DriverHome withOnline({required bool isOnline}) => DriverHome(
    position: position,
    isOnline: isOnline,
    nextBooking: nextBooking,
  );

  @override
  List<Object?> get props => [position, isOnline, nextBooking];
}

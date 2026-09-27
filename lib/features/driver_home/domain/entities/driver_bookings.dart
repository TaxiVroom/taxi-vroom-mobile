import 'package:equatable/equatable.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';

// The "Réservations" tab: rides to pick in the driver's area, and the ones
// already accepted. Both sorted by pickup time, the next one first.
class DriverBookings extends Equatable {
  const DriverBookings({required this.available, required this.accepted});

  final List<DriverBooking> available;
  final List<DriverBooking> accepted;

  @override
  List<Object?> get props => [available, accepted];
}

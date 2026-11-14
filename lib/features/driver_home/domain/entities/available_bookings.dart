import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/paged_list.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';

// The first page of "Disponibles" and the position it was read around: the
// next pages are read around the same one, so a driver on the road does not
// get pages of another zone mixed in.
class AvailableBookings extends Equatable {
  const AvailableBookings({required this.around, required this.bookings});

  final Coordinates around;
  final PagedList<DriverBooking> bookings;

  @override
  List<Object?> get props => [around, bookings];
}

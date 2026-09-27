part of 'driver_bookings_bloc.dart';

sealed class DriverBookingsEvent extends Equatable {
  const DriverBookingsEvent();

  @override
  List<Object?> get props => [];
}

// The tab is shown, or the driver taps "Réessayer".
final class DriverBookingsRequested extends DriverBookingsEvent {
  const DriverBookingsRequested();
}

// "Accepter" on an available booking.
final class DriverBookingAccepted extends DriverBookingsEvent {
  const DriverBookingAccepted({required this.bookingId});

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

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

// "Se désister" on an accepted booking, before it starts.
final class DriverBookingWithdrawn extends DriverBookingsEvent {
  const DriverBookingWithdrawn({required this.bookingId});

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

// "Refuser" on an available booking: it leaves the driver's list.
final class DriverBookingRefused extends DriverBookingsEvent {
  const DriverBookingRefused({required this.bookingId});

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

// "Je pars" on an accepted booking whose deadline passed.
final class DriverBookingDeparted extends DriverBookingsEvent {
  const DriverBookingDeparted({required this.bookingId});

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

// "Accepter" on an available booking.
final class DriverBookingAccepted extends DriverBookingsEvent {
  const DriverBookingAccepted({required this.bookingId});

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

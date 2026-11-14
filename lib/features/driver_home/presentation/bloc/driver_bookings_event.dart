part of 'driver_bookings_bloc.dart';

sealed class DriverBookingsEvent extends Equatable {
  const DriverBookingsEvent();

  @override
  List<Object?> get props => [];
}

// The tab is shown, a notification came or the driver taps "Réessayer": the
// list shown is loaded again from its first page.
final class DriverBookingsRequested extends DriverBookingsEvent {
  const DriverBookingsRequested();
}

// "Disponibles" or "Acceptées" is tapped: that list is loaded from its first
// page, even if it is the one shown (decision of the user, 2026-11-14).
final class DriverBookingsListSelected extends DriverBookingsEvent {
  const DriverBookingsListSelected(this.list);

  final DriverBookingsList list;

  @override
  List<Object?> get props => [list];
}

// The driver scrolled near the last card of the list shown.
final class DriverBookingsNextPageRequested extends DriverBookingsEvent {
  const DriverBookingsNextPageRequested();
}

// The driver home is shown: each notification received on screen or touched
// reloads the lists, e.g. "Réservation annulée" by the passenger. Spec
// mes-courses-a-jour.md.
final class DriverBookingsPushesWatched extends DriverBookingsEvent {
  const DriverBookingsPushesWatched();
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

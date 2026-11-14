part of 'driver_bookings_bloc.dart';

// The two lists of the "Réservations" tab.
enum DriverBookingsList { available, accepted }

sealed class DriverBookingsState extends Equatable {
  const DriverBookingsState({required this.shown});

  // The list the driver looks at: the only one kept in memory.
  final DriverBookingsList shown;

  @override
  List<Object?> get props => [shown];
}

// The loader replaces the list.
final class DriverBookingsLoading extends DriverBookingsState {
  const DriverBookingsLoading({required super.shown});
}

final class DriverBookingsReady extends DriverBookingsState {
  const DriverBookingsReady({
    required super.shown,
    required this.bookings,
    this.around,
    this.answeringId,
    this.isRefusing = false,
    this.isLoadingNextPage = false,
    this.failureMessage,
    this.nextPageFailureMessage,
  });

  // The pages of the shown list loaded so far.
  final PagedList<DriverBooking> bookings;

  // The position "Disponibles" was read around: its next pages use the same.
  // Null for "Acceptées".
  final Coordinates? around;

  // The booking being accepted, refused or given up, if any.
  final String? answeringId;

  // The answer being sent is "Refuser": its button shows the loader.
  final bool isRefusing;

  // The loader under the last card.
  final bool isLoadingNextPage;

  // Why the last answer failed.
  final String? failureMessage;

  // Why the last page could not be loaded.
  final String? nextPageFailureMessage;

  DriverBookingsReady withAnswering(
    String bookingId, {
    required bool isRefusing,
  }) => DriverBookingsReady(
    shown: shown,
    bookings: bookings,
    around: around,
    answeringId: bookingId,
    isRefusing: isRefusing,
  );

  // The messages are never kept: each one is told once.
  DriverBookingsReady copyWith({
    PagedList<DriverBooking>? bookings,
    bool? isLoadingNextPage,
    String? nextPageFailureMessage,
  }) => DriverBookingsReady(
    shown: shown,
    bookings: bookings ?? this.bookings,
    around: around,
    isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
    nextPageFailureMessage: nextPageFailureMessage,
  );

  @override
  List<Object?> get props => [
    shown,
    bookings,
    around,
    answeringId,
    isRefusing,
    isLoadingNextPage,
    failureMessage,
    nextPageFailureMessage,
  ];
}

// "Accepter" went through: the booking is now an accepted one. The list is
// loaded again right after.
final class DriverBookingsAccepted extends DriverBookingsState {
  const DriverBookingsAccepted({required super.shown});
}

// "Je pars" went through: the driver now drives to the passenger. The list is
// loaded again right after.
final class DriverBookingsDeparted extends DriverBookingsState {
  const DriverBookingsDeparted({required super.shown, required this.ride});

  final DriverRide ride;

  @override
  List<Object?> get props => [shown, ride];
}

final class DriverBookingsFailure extends DriverBookingsState {
  const DriverBookingsFailure({required super.shown, required this.message});

  final String message;

  @override
  List<Object?> get props => [shown, message];
}

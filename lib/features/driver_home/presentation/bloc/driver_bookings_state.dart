part of 'driver_bookings_bloc.dart';

sealed class DriverBookingsState extends Equatable {
  const DriverBookingsState();

  @override
  List<Object?> get props => [];
}

final class DriverBookingsLoading extends DriverBookingsState {
  const DriverBookingsLoading();
}

final class DriverBookingsReady extends DriverBookingsState {
  const DriverBookingsReady({
    required this.bookings,
    this.answeringId,
    this.isRefusing = false,
    this.failureMessage,
  });

  final DriverBookings bookings;

  // The booking being accepted, refused or given up, if any.
  final String? answeringId;

  // The answer being sent is "Refuser": its button shows the loader.
  final bool isRefusing;

  // Why the last answer failed.
  final String? failureMessage;

  @override
  List<Object?> get props => [
    bookings,
    answeringId,
    isRefusing,
    failureMessage,
  ];
}

// "Je pars" went through: the driver now drives to the passenger. The lists
// are loaded again right after.
final class DriverBookingsDeparted extends DriverBookingsState {
  const DriverBookingsDeparted({required this.ride});

  final DriverRide ride;

  @override
  List<Object?> get props => [ride];
}

final class DriverBookingsFailure extends DriverBookingsState {
  const DriverBookingsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

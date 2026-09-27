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
    this.acceptingId,
    this.failureMessage,
  });

  final DriverBookings bookings;

  // The booking being accepted, if any.
  final String? acceptingId;

  // Why the last acceptance failed.
  final String? failureMessage;

  @override
  List<Object?> get props => [bookings, acceptingId, failureMessage];
}

final class DriverBookingsFailure extends DriverBookingsState {
  const DriverBookingsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

part of 'ride_history_bloc.dart';

sealed class RideHistoryEvent extends Equatable {
  const RideHistoryEvent();

  @override
  List<Object?> get props => [];
}

// The "Courses" tab is opened, a ride was booked or "Réessayer" is tapped.
final class RideHistoryRequested extends RideHistoryEvent {
  const RideHistoryRequested();
}

final class BookingCancelRequested extends RideHistoryEvent {
  const BookingCancelRequested({required this.bookingId});

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

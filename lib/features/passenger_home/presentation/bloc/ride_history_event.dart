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

// The passenger home is shown: each notification received on screen or
// touched reloads the list, e.g. "Réservation confirmée", which no screen
// opens. Spec mes-courses-a-jour.md.
final class RideHistoryPushesWatched extends RideHistoryEvent {
  const RideHistoryPushesWatched();
}

final class BookingCancelRequested extends RideHistoryEvent {
  const BookingCancelRequested({required this.bookingId});

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

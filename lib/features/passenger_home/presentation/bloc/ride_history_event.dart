part of 'ride_history_bloc.dart';

sealed class RideHistoryEvent extends Equatable {
  const RideHistoryEvent();

  @override
  List<Object?> get props => [];
}

// The "Courses" tab is opened, a ride was booked, a notification came or
// "Réessayer" is tapped: the list shown is loaded again from its first page,
// the other one is forgotten.
final class RideHistoryRequested extends RideHistoryEvent {
  const RideHistoryRequested();
}

// "À venir" or "Passées" is tapped.
final class RideHistoryListSelected extends RideHistoryEvent {
  const RideHistoryListSelected(this.list);

  final RideHistoryList list;

  @override
  List<Object?> get props => [list];
}

// The passenger scrolled near the last card of the list shown.
final class RideHistoryNextPageRequested extends RideHistoryEvent {
  const RideHistoryNextPageRequested();
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

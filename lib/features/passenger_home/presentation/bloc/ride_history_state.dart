part of 'ride_history_bloc.dart';

// The two lists of "Mes courses".
enum RideHistoryList { upcoming, past }

sealed class RideHistoryState extends Equatable {
  const RideHistoryState({required this.shown});

  // The list the passenger looks at.
  final RideHistoryList shown;

  @override
  List<Object?> get props => [shown];
}

// Nothing is loaded: the loader replaces the list.
final class RideHistoryLoading extends RideHistoryState {
  const RideHistoryLoading({required super.shown});
}

// Each list keeps the pages loaded so far. A list not opened yet is null: the
// loader replaces it until its first page comes.
final class RideHistoryReady extends RideHistoryState {
  const RideHistoryReady({
    required super.shown,
    this.upcoming,
    this.past,
    this.cancellingId,
    this.isLoadingNextPage = false,
    this.failureMessage,
    this.nextPageFailureMessage,
  });

  final PagedList<BookedRide>? upcoming;
  final PagedList<PastRide>? past;

  // The booking being cancelled, if any.
  final String? cancellingId;

  // The loader under the last card.
  final bool isLoadingNextPage;

  // Why the last cancellation failed.
  final String? failureMessage;

  // Why the last page could not be loaded.
  final String? nextPageFailureMessage;

  // Copies the lists, the shown one and the booking being cancelled. The
  // messages are never kept: each one is told once.
  RideHistoryReady copyWith({
    RideHistoryList? shown,
    PagedList<BookedRide>? upcoming,
    PagedList<PastRide>? past,
    bool? isLoadingNextPage,
    String? nextPageFailureMessage,
  }) => RideHistoryReady(
    shown: shown ?? this.shown,
    upcoming: upcoming ?? this.upcoming,
    past: past ?? this.past,
    cancellingId: cancellingId,
    isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
    nextPageFailureMessage: nextPageFailureMessage,
  );

  @override
  List<Object?> get props => [
    shown,
    upcoming,
    past,
    cancellingId,
    isLoadingNextPage,
    failureMessage,
    nextPageFailureMessage,
  ];
}

final class RideHistoryFailure extends RideHistoryState {
  const RideHistoryFailure({required super.shown, required this.message});

  final String message;

  @override
  List<Object?> get props => [shown, message];
}

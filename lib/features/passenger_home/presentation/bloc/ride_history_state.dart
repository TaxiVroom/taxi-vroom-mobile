part of 'ride_history_bloc.dart';

sealed class RideHistoryState extends Equatable {
  const RideHistoryState();

  @override
  List<Object?> get props => [];
}

final class RideHistoryLoading extends RideHistoryState {
  const RideHistoryLoading();
}

final class RideHistoryReady extends RideHistoryState {
  const RideHistoryReady({
    required this.history,
    this.cancellingId,
    this.failureMessage,
  });

  final RideHistory history;

  // The booking being cancelled, if any.
  final String? cancellingId;

  // Why the last cancellation failed.
  final String? failureMessage;

  @override
  List<Object?> get props => [history, cancellingId, failureMessage];
}

final class RideHistoryFailure extends RideHistoryState {
  const RideHistoryFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

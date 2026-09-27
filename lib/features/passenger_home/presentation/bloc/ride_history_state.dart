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
  const RideHistoryReady({required this.history});

  final RideHistory history;

  @override
  List<Object?> get props => [history];
}

final class RideHistoryFailure extends RideHistoryState {
  const RideHistoryFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

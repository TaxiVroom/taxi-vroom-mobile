part of 'boarding_bloc.dart';

enum BoardingCodeStatus { typing, checking, correct, incorrect }

sealed class BoardingState extends Equatable {
  const BoardingState();

  @override
  List<Object?> get props => [];
}

final class BoardingInProgress extends BoardingState {
  const BoardingInProgress({
    this.code = '',
    this.codeStatus = BoardingCodeStatus.typing,
    this.waited = Duration.zero,
    this.isSubmitting = false,
    this.failureMessage,
  });

  // The digits typed so far.
  final String code;
  final BoardingCodeStatus codeStatus;

  // Since the driver arrived.
  final Duration waited;

  // Starting the ride or reporting the no-show is in progress.
  final bool isSubmitting;

  final String? failureMessage;

  BoardingInProgress copyWith({
    String? code,
    BoardingCodeStatus? codeStatus,
    Duration? waited,
    bool? isSubmitting,
    String? failureMessage,
    bool clearsFailure = false,
  }) => BoardingInProgress(
    code: code ?? this.code,
    codeStatus: codeStatus ?? this.codeStatus,
    waited: waited ?? this.waited,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    failureMessage: clearsFailure
        ? null
        : failureMessage ?? this.failureMessage,
  );

  @override
  List<Object?> get props => [
    code,
    codeStatus,
    waited,
    isSubmitting,
    failureMessage,
  ];
}

final class BoardingRideStarted extends BoardingState {
  const BoardingRideStarted();
}

final class BoardingNoShowReported extends BoardingState {
  const BoardingNoShowReported();
}

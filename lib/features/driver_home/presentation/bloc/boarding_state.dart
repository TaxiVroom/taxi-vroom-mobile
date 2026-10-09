part of 'boarding_bloc.dart';

enum BoardingCodeStatus { typing, incorrect, locked }

sealed class BoardingState extends Equatable {
  const BoardingState();

  @override
  List<Object?> get props => [];
}

final class BoardingInProgress extends BoardingState {
  const BoardingInProgress({
    this.code = '',
    this.codeStatus = BoardingCodeStatus.typing,
    this.attemptsLeft = 0,
    this.waited = Duration.zero,
    this.isSubmitting = false,
    this.failureMessage,
  });

  // The digits typed so far.
  final String code;
  final BoardingCodeStatus codeStatus;

  // After an incorrect code.
  final int attemptsLeft;

  // Since the driver arrived.
  final Duration waited;

  // Starting the ride or reporting the no-show is in progress.
  final bool isSubmitting;

  final String? failureMessage;

  bool get canType => !isSubmitting && codeStatus != BoardingCodeStatus.locked;

  bool get canReportNoShow => ReportNoShowUseCase.canReport(waited: waited);

  // A complete code, not refused yet.
  bool get canStart =>
      canType &&
      codeStatus == BoardingCodeStatus.typing &&
      code.length == StartRideUseCase.codeLength;

  BoardingInProgress copyWith({
    String? code,
    BoardingCodeStatus? codeStatus,
    int? attemptsLeft,
    Duration? waited,
    bool? isSubmitting,
    String? failureMessage,
    bool clearsFailure = false,
  }) => BoardingInProgress(
    code: code ?? this.code,
    codeStatus: codeStatus ?? this.codeStatus,
    attemptsLeft: attemptsLeft ?? this.attemptsLeft,
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
    attemptsLeft,
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

final class BoardingWithdrawn extends BoardingState {
  const BoardingWithdrawn();
}

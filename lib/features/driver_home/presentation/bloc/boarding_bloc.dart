import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/ride_start.dart';
import 'package:mobile/features/driver_home/domain/usecases/report_no_show_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/start_ride_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/withdraw_from_ride_usecase.dart';

part 'boarding_event.dart';
part 'boarding_state.dart';

/// Mockup screen 6: the driver waits for the passenger and types their
/// boarding code to start the ride.
class BoardingBloc extends Bloc<BoardingEvent, BoardingState> {
  BoardingBloc({
    required String rideId,
    required DateTime arrivedAt,
    required StartRideUseCase startRideUseCase,
    required ReportNoShowUseCase reportNoShowUseCase,
    required WithdrawFromRideUseCase withdrawFromRideUseCase,
  }) : _rideId = rideId,
       _arrivedAt = arrivedAt,
       _startRideUseCase = startRideUseCase,
       _reportNoShowUseCase = reportNoShowUseCase,
       _withdrawFromRideUseCase = withdrawFromRideUseCase,
       super(const BoardingInProgress()) {
    on<BoardingWaitStarted>(_onWaitStarted);
    on<_BoardingTicked>(_onTicked);
    on<BoardingDigitPressed>(_onDigitPressed);
    on<BoardingDigitErased>(_onDigitErased);
    on<BoardingRideStartRequested>(_onRideStartRequested);
    on<BoardingNoShowRequested>(_onNoShowRequested);
    on<BoardingWithdrawRequested>(_onWithdrawRequested);
  }

  final String _rideId;
  final DateTime _arrivedAt;
  final StartRideUseCase _startRideUseCase;
  final ReportNoShowUseCase _reportNoShowUseCase;
  final WithdrawFromRideUseCase _withdrawFromRideUseCase;

  Timer? _clock;

  void _onWaitStarted(BoardingWaitStarted event, Emitter<BoardingState> emit) {
    _clock?.cancel();
    _clock = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const _BoardingTicked()),
    );
    add(const _BoardingTicked());
  }

  void _onTicked(_BoardingTicked event, Emitter<BoardingState> emit) {
    final currentState = state;
    if (currentState is! BoardingInProgress) return;
    emit(currentState.copyWith(waited: DateTime.now().difference(_arrivedAt)));
  }

  void _onDigitPressed(
    BoardingDigitPressed event,
    Emitter<BoardingState> emit,
  ) {
    final currentState = state;
    if (currentState is! BoardingInProgress ||
        !currentState.canType ||
        currentState.code.length == StartRideUseCase.codeLength) {
      return;
    }
    emit(
      currentState.copyWith(
        code: '${currentState.code}${event.digit}',
        clearsFailure: true,
      ),
    );
  }

  void _onDigitErased(BoardingDigitErased event, Emitter<BoardingState> emit) {
    final currentState = state;
    if (currentState is! BoardingInProgress ||
        !currentState.canType ||
        currentState.code.isEmpty) {
      return;
    }
    final code = currentState.code;
    emit(
      currentState.copyWith(
        code: code.substring(0, code.length - 1),
        codeStatus: BoardingCodeStatus.typing,
        clearsFailure: true,
      ),
    );
  }

  // The server checks the code and starts the ride at once.
  Future<void> _onRideStartRequested(
    BoardingRideStartRequested event,
    Emitter<BoardingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BoardingInProgress || !currentState.canStart) return;

    emit(currentState.copyWith(isSubmitting: true, clearsFailure: true));
    final result = await _startRideUseCase(
      rideId: _rideId,
      boardingCode: currentState.code,
    );
    switch (result) {
      case Ok(value: RideStartAccepted()):
        _clock?.cancel();
        emit(const BoardingRideStarted());
      case Ok(value: RideStartWrongCode(:final attemptsLeft)):
        emit(
          currentState.copyWith(
            codeStatus: BoardingCodeStatus.incorrect,
            attemptsLeft: attemptsLeft,
          ),
        );
      case Ok(value: RideStartLocked()):
        emit(currentState.copyWith(codeStatus: BoardingCodeStatus.locked));
      case Error(:final error):
        emit(currentState.copyWith(failureMessage: error.message));
    }
  }

  Future<void> _onNoShowRequested(
    BoardingNoShowRequested event,
    Emitter<BoardingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BoardingInProgress ||
        currentState.isSubmitting ||
        !currentState.canReportNoShow) {
      return;
    }

    emit(currentState.copyWith(isSubmitting: true, clearsFailure: true));
    final result = await _reportNoShowUseCase(_rideId);
    _emitOutcome(emit, currentState, result, const BoardingNoShowReported());
  }

  Future<void> _onWithdrawRequested(
    BoardingWithdrawRequested event,
    Emitter<BoardingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BoardingInProgress || currentState.isSubmitting) {
      return;
    }

    emit(currentState.copyWith(isSubmitting: true, clearsFailure: true));
    final result = await _withdrawFromRideUseCase(_rideId);
    _emitOutcome(emit, currentState, result, const BoardingWithdrawn());
  }

  void _emitOutcome(
    Emitter<BoardingState> emit,
    BoardingInProgress previous,
    Result<void> result,
    BoardingState outcome,
  ) {
    switch (result) {
      case Ok():
        _clock?.cancel();
        emit(outcome);
      case Error(:final error):
        emit(
          previous.copyWith(isSubmitting: false, failureMessage: error.message),
        );
    }
  }

  @override
  Future<void> close() {
    _clock?.cancel();
    return super.close();
  }
}

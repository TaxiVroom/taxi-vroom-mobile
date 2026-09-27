import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/usecases/report_no_show_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/start_ride_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/verify_boarding_code_usecase.dart';

part 'boarding_event.dart';
part 'boarding_state.dart';

/// Mockup screen 6: the driver waits for the passenger and types their
/// boarding code to start the ride.
class BoardingBloc extends Bloc<BoardingEvent, BoardingState> {
  BoardingBloc({
    required String rideId,
    required DateTime arrivedAt,
    required VerifyBoardingCodeUseCase verifyBoardingCodeUseCase,
    required StartRideUseCase startRideUseCase,
    required ReportNoShowUseCase reportNoShowUseCase,
  }) : _rideId = rideId,
       _arrivedAt = arrivedAt,
       _verifyBoardingCodeUseCase = verifyBoardingCodeUseCase,
       _startRideUseCase = startRideUseCase,
       _reportNoShowUseCase = reportNoShowUseCase,
       super(const BoardingInProgress()) {
    on<BoardingWaitStarted>(_onWaitStarted);
    on<_BoardingTicked>(_onTicked);
    on<BoardingDigitPressed>(_onDigitPressed);
    on<BoardingDigitErased>(_onDigitErased);
    on<BoardingRideStartRequested>(_onRideStartRequested);
    on<BoardingNoShowRequested>(_onNoShowRequested);
  }

  final String _rideId;
  final DateTime _arrivedAt;
  final VerifyBoardingCodeUseCase _verifyBoardingCodeUseCase;
  final StartRideUseCase _startRideUseCase;
  final ReportNoShowUseCase _reportNoShowUseCase;

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

  Future<void> _onDigitPressed(
    BoardingDigitPressed event,
    Emitter<BoardingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BoardingInProgress ||
        currentState.code.length == VerifyBoardingCodeUseCase.codeLength) {
      return;
    }

    final code = '${currentState.code}${event.digit}';
    if (code.length < VerifyBoardingCodeUseCase.codeLength) {
      emit(currentState.copyWith(code: code, clearsFailure: true));
      return;
    }

    emit(
      currentState.copyWith(
        code: code,
        codeStatus: BoardingCodeStatus.checking,
        clearsFailure: true,
      ),
    );
    final result = await _verifyBoardingCodeUseCase(
      rideId: _rideId,
      code: code,
    );
    final afterCheck = state;
    // The driver may have erased a digit meanwhile.
    if (afterCheck is! BoardingInProgress || afterCheck.code != code) return;
    emit(
      switch (result) {
        Ok(value: true) => afterCheck.copyWith(
          codeStatus: BoardingCodeStatus.correct,
        ),
        Ok(value: false) => afterCheck.copyWith(
          codeStatus: BoardingCodeStatus.incorrect,
        ),
        Error(:final error) => afterCheck.copyWith(
          codeStatus: BoardingCodeStatus.typing,
          failureMessage: error.message,
        ),
      },
    );
  }

  void _onDigitErased(BoardingDigitErased event, Emitter<BoardingState> emit) {
    final currentState = state;
    if (currentState is! BoardingInProgress || currentState.code.isEmpty) {
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

  Future<void> _onRideStartRequested(
    BoardingRideStartRequested event,
    Emitter<BoardingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BoardingInProgress ||
        currentState.isSubmitting ||
        currentState.codeStatus != BoardingCodeStatus.correct) {
      return;
    }

    emit(currentState.copyWith(isSubmitting: true, clearsFailure: true));
    final result = await _startRideUseCase(_rideId);
    _emitOutcome(emit, currentState, result, const BoardingRideStarted());
  }

  Future<void> _onNoShowRequested(
    BoardingNoShowRequested event,
    Emitter<BoardingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BoardingInProgress || currentState.isSubmitting) {
      return;
    }

    emit(currentState.copyWith(isSubmitting: true, clearsFailure: true));
    final result = await _reportNoShowUseCase(_rideId);
    _emitOutcome(emit, currentState, result, const BoardingNoShowReported());
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

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/usecases/watch_pushed_rides_usecase.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride_history.dart';
import 'package:mobile/features/passenger_home/domain/usecases/cancel_booking_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_ride_history_usecase.dart';

part 'ride_history_event.dart';
part 'ride_history_state.dart';

class RideHistoryBloc extends Bloc<RideHistoryEvent, RideHistoryState> {
  RideHistoryBloc({
    required LoadRideHistoryUseCase loadRideHistoryUseCase,
    required CancelBookingUseCase cancelBookingUseCase,
    required WatchPushedRidesUseCase watchPushedRidesUseCase,
  }) : _loadRideHistoryUseCase = loadRideHistoryUseCase,
       _cancelBookingUseCase = cancelBookingUseCase,
       _watchPushedRidesUseCase = watchPushedRidesUseCase,
       super(const RideHistoryLoading()) {
    on<RideHistoryRequested>(_onRequested);
    on<RideHistoryPushesWatched>(_onPushesWatched);
    on<BookingCancelRequested>(_onBookingCancelRequested);
  }

  final LoadRideHistoryUseCase _loadRideHistoryUseCase;
  final CancelBookingUseCase _cancelBookingUseCase;
  final WatchPushedRidesUseCase _watchPushedRidesUseCase;

  // RideHistoryPushesWatched may come again: the notifications are followed
  // once.
  bool _watchesPushes = false;

  Future<void> _onRequested(
    RideHistoryRequested event,
    Emitter<RideHistoryState> emit,
  ) async {
    // A refresh keeps the current list on screen instead of a spinner.
    if (state is! RideHistoryReady) emit(const RideHistoryLoading());
    await _load(emit);
  }

  // The same stream as PassengerFlowBloc's: both can listen to it, Firebase
  // broadcasts onMessage and onMessageOpenedApp.
  // Docs: https://firebase.google.com/docs/cloud-messaging/flutter/receive
  Future<void> _onPushesWatched(
    RideHistoryPushesWatched event,
    Emitter<RideHistoryState> emit,
  ) async {
    if (_watchesPushes) return;
    _watchesPushes = true;
    await emit.onEach<String?>(
      _watchPushedRidesUseCase(),
      onData: (_) => add(const RideHistoryRequested()),
    );
  }

  Future<void> _onBookingCancelRequested(
    BookingCancelRequested event,
    Emitter<RideHistoryState> emit,
  ) async {
    // One cancellation at a time: a second tap would send it twice.
    final currentState = state;
    if (currentState is! RideHistoryReady ||
        currentState.cancellingId != null) {
      return;
    }
    emit(
      RideHistoryReady(
        history: currentState.history,
        cancellingId: event.bookingId,
      ),
    );
    switch (await _cancelBookingUseCase(event.bookingId)) {
      case Ok():
        await _load(emit);
      // Told by a message. Refused by the server, the booking changed
      // meanwhile (e.g. it started): the list is reloaded to show it as it
      // is now. A lost connection keeps it as it was.
      case Error(:final error):
        emit(
          RideHistoryReady(
            history: currentState.history,
            failureMessage: error.message,
          ),
        );
        if (error is ValidationFailure) await _load(emit);
    }
  }

  Future<void> _load(Emitter<RideHistoryState> emit) async {
    switch (await _loadRideHistoryUseCase()) {
      case Ok(:final value):
        emit(RideHistoryReady(history: value));
      case Error(:final error):
        emit(RideHistoryFailure(message: error.message));
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/paged_list.dart';
import 'package:mobile/core/domain/usecases/watch_pushed_rides_usecase.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/booked_ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/past_ride.dart';
import 'package:mobile/features/passenger_home/domain/usecases/cancel_booking_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_bookings_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_past_rides_usecase.dart';

part 'ride_history_event.dart';
part 'ride_history_state.dart';

// Spec taxi-vroom-api/docs/specs/mes-courses-par-pages.md.
class RideHistoryBloc extends Bloc<RideHistoryEvent, RideHistoryState> {
  RideHistoryBloc({
    required LoadBookingsUseCase loadBookingsUseCase,
    required LoadPastRidesUseCase loadPastRidesUseCase,
    required CancelBookingUseCase cancelBookingUseCase,
    required WatchPushedRidesUseCase watchPushedRidesUseCase,
  }) : _loadBookingsUseCase = loadBookingsUseCase,
       _loadPastRidesUseCase = loadPastRidesUseCase,
       _cancelBookingUseCase = cancelBookingUseCase,
       _watchPushedRidesUseCase = watchPushedRidesUseCase,
       super(const RideHistoryLoading(shown: RideHistoryList.upcoming)) {
    on<RideHistoryRequested>(_onRequested);
    on<RideHistoryListSelected>(_onListSelected);
    on<RideHistoryNextPageRequested>(_onNextPageRequested);
    on<RideHistoryPushesWatched>(_onPushesWatched);
    on<BookingCancelRequested>(_onBookingCancelRequested);
  }

  final LoadBookingsUseCase _loadBookingsUseCase;
  final LoadPastRidesUseCase _loadPastRidesUseCase;
  final CancelBookingUseCase _cancelBookingUseCase;
  final WatchPushedRidesUseCase _watchPushedRidesUseCase;

  // RideHistoryPushesWatched may come again: the notifications are followed
  // once.
  bool _watchesPushes = false;

  // Moves each time a list is loaded from its first page. An answer that
  // comes after that is dropped: the new load takes over.
  int _generation = 0;

  Future<void> _onRequested(
    RideHistoryRequested event,
    Emitter<RideHistoryState> emit,
  ) => _reload(emit);

  // The loader shows each time the API is asked, never the old list
  // (decision of the user, 2026-11-11).
  Future<void> _reload(Emitter<RideHistoryState> emit) async {
    final list = state.shown;
    _generation++;
    emit(RideHistoryLoading(shown: list));
    await _loadFirstPage(list, emit);
  }

  Future<void> _onListSelected(
    RideHistoryListSelected event,
    Emitter<RideHistoryState> emit,
  ) async {
    final list = event.list;
    final current = state;
    if (current is RideHistoryReady) {
      // A list keeps the pages it loaded. A page on its way for the list left
      // is dropped.
      emit(current.copyWith(shown: list, isLoadingNextPage: false));
      final isLoaded = switch (list) {
        RideHistoryList.upcoming => current.upcoming != null,
        RideHistoryList.past => current.past != null,
      };
      if (isLoaded) return;
    } else {
      _generation++;
      emit(RideHistoryLoading(shown: list));
    }
    await _loadFirstPage(list, emit);
  }

  Future<void> _loadFirstPage(
    RideHistoryList list,
    Emitter<RideHistoryState> emit,
  ) async {
    final generation = _generation;
    switch (list) {
      case RideHistoryList.upcoming:
        final result = await _loadBookingsUseCase(page: 0);
        if (generation != _generation) return;
        switch (result) {
          case Ok(:final value):
            emit(_readyWith(list).copyWith(upcoming: value));
          case Error(:final error):
            _emitFailure(emit, list, error);
        }
      case RideHistoryList.past:
        final result = await _loadPastRidesUseCase(page: 0);
        if (generation != _generation) return;
        switch (result) {
          case Ok(:final value):
            emit(_readyWith(list).copyWith(past: value));
          case Error(:final error):
            _emitFailure(emit, list, error);
        }
    }
  }

  // The lists already loaded, or none when the loader was on.
  RideHistoryReady _readyWith(RideHistoryList list) {
    final current = state;
    return current is RideHistoryReady
        ? current
        : RideHistoryReady(shown: list);
  }

  // Only the list looked at tells the failure: another one, left meanwhile,
  // will be asked again when it is opened.
  void _emitFailure(
    Emitter<RideHistoryState> emit,
    RideHistoryList list,
    Failure error,
  ) {
    if (state.shown != list) return;
    emit(RideHistoryFailure(shown: list, message: error.message));
  }

  Future<void> _onNextPageRequested(
    RideHistoryNextPageRequested event,
    Emitter<RideHistoryState> emit,
  ) async {
    final current = state;
    if (current is! RideHistoryReady ||
        current.isLoadingNextPage ||
        current.cancellingId != null) {
      return;
    }
    final list = current.shown;
    final generation = _generation;
    switch (list) {
      case RideHistoryList.upcoming:
        final loaded = current.upcoming;
        if (loaded == null || !loaded.hasMore) return;
        emit(current.copyWith(isLoadingNextPage: true));
        final result = await _loadBookingsUseCase(page: loaded.nextPage);
        final latest = _stateWaitingFor(list, generation);
        if (latest == null) return;
        switch (result) {
          case Ok(:final value):
            emit(
              latest.copyWith(
                upcoming: loaded.appended(value, idOf: (ride) => ride.id),
                isLoadingNextPage: false,
              ),
            );
          case Error(:final error):
            emit(
              latest.copyWith(
                isLoadingNextPage: false,
                nextPageFailureMessage: error.message,
              ),
            );
        }
      case RideHistoryList.past:
        final loaded = current.past;
        if (loaded == null || !loaded.hasMore) return;
        emit(current.copyWith(isLoadingNextPage: true));
        final result = await _loadPastRidesUseCase(page: loaded.nextPage);
        final latest = _stateWaitingFor(list, generation);
        if (latest == null) return;
        switch (result) {
          case Ok(:final value):
            emit(
              latest.copyWith(
                past: loaded.appended(value, idOf: (ride) => ride.id),
                isLoadingNextPage: false,
              ),
            );
          case Error(:final error):
            emit(
              latest.copyWith(
                isLoadingNextPage: false,
                nextPageFailureMessage: error.message,
              ),
            );
        }
    }
  }

  // The state a page on its way comes back to: null when a load took over or
  // the passenger moved to the other list, the page is then dropped.
  RideHistoryReady? _stateWaitingFor(RideHistoryList list, int generation) {
    final latest = state;
    if (generation != _generation ||
        latest is! RideHistoryReady ||
        latest.shown != list ||
        !latest.isLoadingNextPage) {
      return null;
    }
    return latest;
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
        shown: currentState.shown,
        upcoming: currentState.upcoming,
        past: currentState.past,
        cancellingId: event.bookingId,
      ),
    );
    switch (await _cancelBookingUseCase(event.bookingId)) {
      // The list is loaded again from its first page (decision of the user,
      // 2026-11-14).
      case Ok():
        await _reload(emit);
      // Told by a message. Refused by the server, the booking changed
      // meanwhile (e.g. it started): the list is loaded again to show it as
      // it is now. A lost connection keeps it as it was.
      case Error(:final error):
        emit(
          RideHistoryReady(
            shown: currentState.shown,
            upcoming: currentState.upcoming,
            past: currentState.past,
            failureMessage: error.message,
          ),
        );
        if (error is ValidationFailure) await _reload(emit);
    }
  }
}

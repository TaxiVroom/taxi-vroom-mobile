import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/paged_list.dart';
import 'package:mobile/core/domain/usecases/watch_pushed_rides_usecase.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_booking.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/usecases/accept_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/depart_for_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_accepted_bookings_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_available_bookings_page_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_available_bookings_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/refuse_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/withdraw_from_booking_usecase.dart';

part 'driver_bookings_event.dart';
part 'driver_bookings_state.dart';

/// Mockup screen 9: the "Réservations" tab. Spec
/// taxi-vroom-api/docs/specs/reservations-chauffeur-par-pages.md.
class DriverBookingsBloc
    extends Bloc<DriverBookingsEvent, DriverBookingsState> {
  DriverBookingsBloc({
    required LoadAvailableBookingsUseCase loadAvailableBookingsUseCase,
    required LoadAvailableBookingsPageUseCase loadAvailableBookingsPageUseCase,
    required LoadAcceptedBookingsUseCase loadAcceptedBookingsUseCase,
    required AcceptBookingUseCase acceptBookingUseCase,
    required WithdrawFromBookingUseCase withdrawFromBookingUseCase,
    required RefuseBookingUseCase refuseBookingUseCase,
    required DepartForBookingUseCase departForBookingUseCase,
    required WatchPushedRidesUseCase watchPushedRidesUseCase,
  }) : _watchPushedRidesUseCase = watchPushedRidesUseCase,
       _loadAvailableBookingsUseCase = loadAvailableBookingsUseCase,
       _loadAvailableBookingsPageUseCase = loadAvailableBookingsPageUseCase,
       _loadAcceptedBookingsUseCase = loadAcceptedBookingsUseCase,
       _acceptBookingUseCase = acceptBookingUseCase,
       _withdrawFromBookingUseCase = withdrawFromBookingUseCase,
       _refuseBookingUseCase = refuseBookingUseCase,
       _departForBookingUseCase = departForBookingUseCase,
       super(const DriverBookingsLoading(shown: DriverBookingsList.available)) {
    on<DriverBookingsRequested>(_onRequested);
    on<DriverBookingsListSelected>(_onListSelected);
    on<DriverBookingsNextPageRequested>(_onNextPageRequested);
    on<DriverBookingAccepted>(_onAccepted);
    on<DriverBookingWithdrawn>(_onWithdrawn);
    on<DriverBookingRefused>(_onRefused);
    on<DriverBookingDeparted>(_onDeparted);
    on<DriverBookingsPushesWatched>(_onPushesWatched);
  }

  final WatchPushedRidesUseCase _watchPushedRidesUseCase;

  // DriverBookingsPushesWatched may come again: the notifications are
  // followed once.
  bool _watchesPushes = false;

  // Moves each time a list is loaded from its first page. An answer that
  // comes after that is dropped: the new load takes over.
  int _generation = 0;

  final LoadAvailableBookingsUseCase _loadAvailableBookingsUseCase;
  final LoadAvailableBookingsPageUseCase _loadAvailableBookingsPageUseCase;
  final LoadAcceptedBookingsUseCase _loadAcceptedBookingsUseCase;
  final AcceptBookingUseCase _acceptBookingUseCase;
  final WithdrawFromBookingUseCase _withdrawFromBookingUseCase;
  final RefuseBookingUseCase _refuseBookingUseCase;
  final DepartForBookingUseCase _departForBookingUseCase;

  // The same stream as the passenger's: Firebase broadcasts onMessage and
  // onMessageOpenedApp.
  // Docs: https://firebase.google.com/docs/cloud-messaging/flutter/receive
  Future<void> _onPushesWatched(
    DriverBookingsPushesWatched event,
    Emitter<DriverBookingsState> emit,
  ) async {
    if (_watchesPushes) return;
    _watchesPushes = true;
    await emit.onEach<String?>(
      _watchPushedRidesUseCase(),
      onData: (_) => add(const DriverBookingsRequested()),
    );
  }

  Future<void> _onRequested(
    DriverBookingsRequested event,
    Emitter<DriverBookingsState> emit,
  ) async {
    if (_isAnswering) return;
    await _reload(emit);
  }

  Future<void> _onListSelected(
    DriverBookingsListSelected event,
    Emitter<DriverBookingsState> emit,
  ) async {
    if (_isAnswering) return;
    // The loader shows each time the API is asked, never the old list
    // (decision of the user, 2026-11-11).
    emit(DriverBookingsLoading(shown: event.list));
    await _loadFirstPage(emit);
  }

  // An answer being sent reloads the list at its end: not under the driver's
  // finger meanwhile.
  bool get _isAnswering {
    final currentState = state;
    return currentState is DriverBookingsReady &&
        currentState.answeringId != null;
  }

  Future<void> _reload(Emitter<DriverBookingsState> emit) async {
    emit(DriverBookingsLoading(shown: state.shown));
    await _loadFirstPage(emit);
  }

  // The first page of the list shown, after the loader was emitted.
  Future<void> _loadFirstPage(Emitter<DriverBookingsState> emit) async {
    final list = state.shown;
    final generation = ++_generation;
    switch (list) {
      case DriverBookingsList.available:
        final result = await _loadAvailableBookingsUseCase();
        if (generation != _generation) return;
        switch (result) {
          case Ok(:final value):
            emit(
              DriverBookingsReady(
                shown: list,
                bookings: value.bookings,
                around: value.around,
              ),
            );
          case Error(:final error):
            emit(DriverBookingsFailure(shown: list, message: error.message));
        }
      case DriverBookingsList.accepted:
        final result = await _loadAcceptedBookingsUseCase(page: 0);
        if (generation != _generation) return;
        switch (result) {
          case Ok(:final value):
            emit(DriverBookingsReady(shown: list, bookings: value));
          case Error(:final error):
            emit(DriverBookingsFailure(shown: list, message: error.message));
        }
    }
  }

  Future<void> _onNextPageRequested(
    DriverBookingsNextPageRequested event,
    Emitter<DriverBookingsState> emit,
  ) async {
    final current = state;
    if (current is! DriverBookingsReady ||
        current.isLoadingNextPage ||
        current.answeringId != null ||
        !current.bookings.hasMore) {
      return;
    }
    final generation = _generation;
    emit(current.copyWith(isLoadingNextPage: true));
    final around = current.around;
    final page = current.bookings.nextPage;
    final result = around == null
        ? await _loadAcceptedBookingsUseCase(page: page)
        : await _loadAvailableBookingsPageUseCase(around: around, page: page);
    final latest = _stateWaitingFor(generation);
    if (latest == null) return;
    switch (result) {
      case Ok(:final value):
        emit(
          latest.copyWith(
            bookings: latest.bookings.appended(
              value,
              idOf: (booking) => booking.id,
            ),
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

  // The state a page on its way comes back to: null when a load or an answer
  // took over meanwhile, the page is then dropped.
  DriverBookingsReady? _stateWaitingFor(int generation) {
    final latest = state;
    if (generation != _generation ||
        latest is! DriverBookingsReady ||
        !latest.isLoadingNextPage) {
      return null;
    }
    return latest;
  }

  Future<void> _onAccepted(
    DriverBookingAccepted event,
    Emitter<DriverBookingsState> emit,
  ) => _answer(
    emit,
    event.bookingId,
    _acceptBookingUseCase.call,
    isAcceptance: true,
  );

  Future<void> _onWithdrawn(
    DriverBookingWithdrawn event,
    Emitter<DriverBookingsState> emit,
  ) => _answer(emit, event.bookingId, _withdrawFromBookingUseCase.call);

  Future<void> _onRefused(
    DriverBookingRefused event,
    Emitter<DriverBookingsState> emit,
  ) => _answer(
    emit,
    event.bookingId,
    _refuseBookingUseCase.call,
    isRefusal: true,
  );

  // Like an answer, but the ride comes back: the home opens the pickup
  // screen from DriverBookingsDeparted.
  Future<void> _onDeparted(
    DriverBookingDeparted event,
    Emitter<DriverBookingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverBookingsReady ||
        currentState.answeringId != null) {
      return;
    }

    _generation++;
    emit(currentState.withAnswering(event.bookingId, isRefusing: false));
    switch (await _departForBookingUseCase(event.bookingId)) {
      case Ok(:final value):
        emit(DriverBookingsDeparted(shown: currentState.shown, ride: value));
        await _reload(emit);
      case Error(:final error):
        await _onAnswerFailed(emit, currentState, error);
    }
  }

  // The tab tells it by a message. A refusal by the server (taken, cancelled,
  // driver busy) means the booking changed meanwhile: the list is loaded again
  // so it shows as it is now. A lost connection keeps it as it was.
  Future<void> _onAnswerFailed(
    Emitter<DriverBookingsState> emit,
    DriverBookingsReady before,
    Failure error,
  ) async {
    emit(
      DriverBookingsReady(
        shown: before.shown,
        bookings: before.bookings,
        around: before.around,
        failureMessage: error.message,
      ),
    );
    if (error is ValidationFailure) await _reload(emit);
  }

  // One answer at a time; the list is loaded again from its first page once
  // it is taken (decision of the user, 2026-11-14).
  Future<void> _answer(
    Emitter<DriverBookingsState> emit,
    String bookingId,
    Future<Result<void>> Function(String bookingId) send, {
    bool isRefusal = false,
    bool isAcceptance = false,
  }) async {
    final currentState = state;
    if (currentState is! DriverBookingsReady ||
        currentState.answeringId != null) {
      return;
    }

    // A page on its way is dropped: the answer loads the list again.
    _generation++;
    emit(currentState.withAnswering(bookingId, isRefusing: isRefusal));
    switch (await send(bookingId)) {
      case Ok():
        if (isAcceptance) {
          emit(DriverBookingsAccepted(shown: currentState.shown));
        }
        await _reload(emit);
      case Error(:final error):
        await _onAnswerFailed(emit, currentState, error);
    }
  }
}

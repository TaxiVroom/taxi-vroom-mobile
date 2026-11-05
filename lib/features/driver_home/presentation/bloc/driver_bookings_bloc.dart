import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/usecases/watch_pushed_rides_usecase.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_bookings.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/usecases/accept_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/depart_for_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_bookings_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/refuse_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/withdraw_from_booking_usecase.dart';

part 'driver_bookings_event.dart';
part 'driver_bookings_state.dart';

/// Mockup screen 9: the "Réservations" tab.
class DriverBookingsBloc
    extends Bloc<DriverBookingsEvent, DriverBookingsState> {
  DriverBookingsBloc({
    required LoadDriverBookingsUseCase loadDriverBookingsUseCase,
    required AcceptBookingUseCase acceptBookingUseCase,
    required WithdrawFromBookingUseCase withdrawFromBookingUseCase,
    required RefuseBookingUseCase refuseBookingUseCase,
    required DepartForBookingUseCase departForBookingUseCase,
    required WatchPushedRidesUseCase watchPushedRidesUseCase,
  }) : _watchPushedRidesUseCase = watchPushedRidesUseCase,
       _loadDriverBookingsUseCase = loadDriverBookingsUseCase,
       _acceptBookingUseCase = acceptBookingUseCase,
       _withdrawFromBookingUseCase = withdrawFromBookingUseCase,
       _refuseBookingUseCase = refuseBookingUseCase,
       _departForBookingUseCase = departForBookingUseCase,
       super(const DriverBookingsLoading()) {
    on<DriverBookingsRequested>(_onRequested);
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

  final LoadDriverBookingsUseCase _loadDriverBookingsUseCase;
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
    // An answer being sent reloads the lists at its end: not under the
    // driver's finger meanwhile.
    final currentState = state;
    if (currentState is DriverBookingsReady &&
        currentState.answeringId != null) {
      return;
    }
    // A refresh keeps the list on screen instead of a loader.
    if (state is! DriverBookingsReady) emit(const DriverBookingsLoading());
    await _reload(emit);
  }

  Future<void> _onAccepted(
    DriverBookingAccepted event,
    Emitter<DriverBookingsState> emit,
  ) => _answer(emit, event.bookingId, _acceptBookingUseCase.call);

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

    emit(
      DriverBookingsReady(
        bookings: currentState.bookings,
        answeringId: event.bookingId,
      ),
    );
    switch (await _departForBookingUseCase(event.bookingId)) {
      case Ok(:final value):
        emit(DriverBookingsDeparted(ride: value));
        await _reload(emit);
      case Error(:final error):
        await _onAnswerFailed(emit, currentState, error);
    }
  }

  // The tab tells it by a message. A refusal by the server (taken, cancelled,
  // driver busy) means the booking changed meanwhile: the lists are reloaded
  // so it shows as it is now. A lost connection keeps them as they were.
  Future<void> _onAnswerFailed(
    Emitter<DriverBookingsState> emit,
    DriverBookingsReady before,
    Failure error,
  ) async {
    emit(
      DriverBookingsReady(
        bookings: before.bookings,
        failureMessage: error.message,
      ),
    );
    if (error is ValidationFailure) await _reload(emit);
  }

  Future<void> _reload(Emitter<DriverBookingsState> emit) async {
    switch (await _loadDriverBookingsUseCase()) {
      case Ok(:final value):
        emit(DriverBookingsReady(bookings: value));
      case Error(:final error):
        emit(DriverBookingsFailure(message: error.message));
    }
  }

  // One answer at a time; the lists are reloaded once it is taken.
  Future<void> _answer(
    Emitter<DriverBookingsState> emit,
    String bookingId,
    Future<Result<void>> Function(String bookingId) send, {
    bool isRefusal = false,
  }) async {
    final currentState = state;
    if (currentState is! DriverBookingsReady ||
        currentState.answeringId != null) {
      return;
    }

    emit(
      DriverBookingsReady(
        bookings: currentState.bookings,
        answeringId: bookingId,
        isRefusing: isRefusal,
      ),
    );
    switch (await send(bookingId)) {
      case Ok():
        await _reload(emit);
      case Error(:final error):
        await _onAnswerFailed(emit, currentState, error);
    }
  }
}

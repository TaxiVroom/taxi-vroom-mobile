import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
  }) : _loadRideHistoryUseCase = loadRideHistoryUseCase,
       _cancelBookingUseCase = cancelBookingUseCase,
       super(const RideHistoryLoading()) {
    on<RideHistoryRequested>(_onRequested);
    on<BookingCancelRequested>(_onBookingCancelRequested);
  }

  final LoadRideHistoryUseCase _loadRideHistoryUseCase;
  final CancelBookingUseCase _cancelBookingUseCase;

  Future<void> _onRequested(
    RideHistoryRequested event,
    Emitter<RideHistoryState> emit,
  ) async {
    // A refresh keeps the current list on screen instead of a spinner.
    if (state is! RideHistoryReady) emit(const RideHistoryLoading());
    await _load(emit);
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
      // The list stays, with the message under it.
      case Error(:final error):
        emit(
          RideHistoryReady(
            history: currentState.history,
            failureMessage: error.message,
          ),
        );
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

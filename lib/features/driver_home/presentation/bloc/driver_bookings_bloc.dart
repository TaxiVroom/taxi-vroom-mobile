import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_bookings.dart';
import 'package:mobile/features/driver_home/domain/usecases/accept_booking_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_bookings_usecase.dart';

part 'driver_bookings_event.dart';
part 'driver_bookings_state.dart';

/// Mockup screen 9: the "Réservations" tab.
class DriverBookingsBloc
    extends Bloc<DriverBookingsEvent, DriverBookingsState> {
  DriverBookingsBloc({
    required LoadDriverBookingsUseCase loadDriverBookingsUseCase,
    required AcceptBookingUseCase acceptBookingUseCase,
  }) : _loadDriverBookingsUseCase = loadDriverBookingsUseCase,
       _acceptBookingUseCase = acceptBookingUseCase,
       super(const DriverBookingsLoading()) {
    on<DriverBookingsRequested>(_onRequested);
    on<DriverBookingAccepted>(_onAccepted);
  }

  final LoadDriverBookingsUseCase _loadDriverBookingsUseCase;
  final AcceptBookingUseCase _acceptBookingUseCase;

  Future<void> _onRequested(
    DriverBookingsRequested event,
    Emitter<DriverBookingsState> emit,
  ) async {
    // A refresh keeps the list on screen instead of a loader.
    if (state is! DriverBookingsReady) emit(const DriverBookingsLoading());
    switch (await _loadDriverBookingsUseCase()) {
      case Ok(:final value):
        emit(DriverBookingsReady(bookings: value));
      case Error(:final error):
        emit(DriverBookingsFailure(message: error.message));
    }
  }

  Future<void> _onAccepted(
    DriverBookingAccepted event,
    Emitter<DriverBookingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverBookingsReady ||
        currentState.acceptingId != null) {
      return;
    }

    emit(
      DriverBookingsReady(
        bookings: currentState.bookings,
        acceptingId: event.bookingId,
      ),
    );
    switch (await _acceptBookingUseCase(event.bookingId)) {
      case Ok():
        switch (await _loadDriverBookingsUseCase()) {
          case Ok(:final value):
            emit(DriverBookingsReady(bookings: value));
          case Error(:final error):
            emit(DriverBookingsFailure(message: error.message));
        }
      case Error(:final error):
        emit(
          DriverBookingsReady(
            bookings: currentState.bookings,
            failureMessage: error.message,
          ),
        );
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/ride_route.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/ride.dart';
import 'package:mobile/features/passenger_home/domain/entities/tracked_ride.dart';
import 'package:mobile/features/passenger_home/domain/usecases/cancel_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/rate_ride_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/watch_ride_usecase.dart';

part 'ride_event.dart';
part 'ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  RideBloc({
    required String rideId,
    required WatchRideUseCase watchRideUseCase,
    required CancelRideUseCase cancelRideUseCase,
    required RateRideUseCase rateRideUseCase,
  }) : _rideId = rideId,
       _watchRideUseCase = watchRideUseCase,
       _cancelRideUseCase = cancelRideUseCase,
       _rateRideUseCase = rateRideUseCase,
       super(const RideLoading()) {
    on<RideStarted>(_onStarted);
    on<RideCancelRequested>(_onCancelRequested);
    on<RideLeft>(_onLeft);
    on<RideRatingSubmitted>(_onRatingSubmitted);
  }

  final String _rideId;
  final WatchRideUseCase _watchRideUseCase;
  final CancelRideUseCase _cancelRideUseCase;
  final RateRideUseCase _rateRideUseCase;

  Future<void> _onStarted(RideStarted event, Emitter<RideState> emit) {
    return emit.forEach<Result<TrackedRide>>(
      _watchRideUseCase(_rideId),
      // Late updates must not bring an ended ride back on screen.
      onData: (result) => state is RideEnded
          ? state
          : switch (result) {
              Ok(:final value) => RideTracking(
                ride: value.ride,
                remainingRoute: value.remainingRoute,
              ),
              Error(:final error) => RideFailure(message: error.message),
            },
    );
  }

  Future<void> _onCancelRequested(
    RideCancelRequested event,
    Emitter<RideState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RideTracking || currentState.isSubmitting) return;

    emit(
      RideTracking(
        ride: currentState.ride,
        remainingRoute: currentState.remainingRoute,
        isSubmitting: true,
      ),
    );
    _emitEndOrFailure(emit, await _cancelRideUseCase(_rideId));
  }

  // Nothing to tell the backend: the search already stopped.
  void _onLeft(RideLeft event, Emitter<RideState> emit) {
    final currentState = state;
    if (currentState is! RideTracking ||
        currentState.ride is! RideNoDriverFound) {
      return;
    }
    emit(const RideEnded());
  }

  Future<void> _onRatingSubmitted(
    RideRatingSubmitted event,
    Emitter<RideState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RideTracking || currentState.isSubmitting) return;

    emit(
      RideTracking(
        ride: currentState.ride,
        remainingRoute: currentState.remainingRoute,
        isSubmitting: true,
      ),
    );
    _emitEndOrFailure(
      emit,
      await _rateRideUseCase(
        rideId: _rideId,
        stars: event.stars,
        compliments: event.compliments,
        tipCents: event.tipCents,
      ),
    );
  }

  void _emitEndOrFailure(Emitter<RideState> emit, Result<void> result) {
    switch (result) {
      case Ok():
        emit(const RideEnded());
      case Error(:final error):
        emit(RideFailure(message: error.message));
    }
  }
}

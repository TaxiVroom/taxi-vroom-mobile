import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_ride.dart';
import 'package:mobile/features/driver_home/domain/entities/routed_ride_request.dart';
import 'package:mobile/features/driver_home/domain/usecases/accept_ride_request_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/decline_ride_request_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_ride_requests_usecase.dart';

part 'ride_request_event.dart';
part 'ride_request_state.dart';

/// Offers the incoming ride requests to an online driver, one at a time,
/// with the countdown to answer.
class RideRequestBloc extends Bloc<RideRequestEvent, RideRequestState> {
  RideRequestBloc({
    required WatchRideRequestsUseCase watchRideRequestsUseCase,
    required AcceptRideRequestUseCase acceptRideRequestUseCase,
    required DeclineRideRequestUseCase declineRideRequestUseCase,
  }) : _watchRideRequestsUseCase = watchRideRequestsUseCase,
       _acceptRideRequestUseCase = acceptRideRequestUseCase,
       _declineRideRequestUseCase = declineRideRequestUseCase,
       super(const RideRequestWaiting()) {
    on<RideRequestsWatched>(_onWatched);
    on<RideRequestsUnwatched>(_onUnwatched);
    on<_RideRequestReceived>(_onReceived);
    on<_RideRequestTicked>(_onTicked);
    on<RideRequestAccepted>(_onAccepted);
    on<RideRequestDeclined>(_onDeclined);
  }

  final WatchRideRequestsUseCase _watchRideRequestsUseCase;
  final AcceptRideRequestUseCase _acceptRideRequestUseCase;
  final DeclineRideRequestUseCase _declineRideRequestUseCase;

  StreamSubscription<Result<RoutedRideRequest>>? _requests;
  Timer? _countdown;

  void _onWatched(RideRequestsWatched event, Emitter<RideRequestState> emit) {
    _stopWatching();
    // E.g. back from a ride: the accepted request is over.
    emit(const RideRequestWaiting());
    _requests = _watchRideRequestsUseCase(
      driverPosition: event.driverPosition,
    ).listen((result) => add(_RideRequestReceived(result)));
  }

  void _onUnwatched(
    RideRequestsUnwatched event,
    Emitter<RideRequestState> emit,
  ) {
    _stopWatching();
    emit(const RideRequestWaiting());
  }

  void _onReceived(
    _RideRequestReceived event,
    Emitter<RideRequestState> emit,
  ) {
    // One request at a time: the others go to other drivers.
    if (state is! RideRequestWaiting) return;
    // A request that could not be read is simply not offered.
    if (event.result case Ok(value: final offer)) {
      emit(
        RideRequestOffered(
          offer: offer,
          secondsLeft: offer.request.secondsLeft(DateTime.now()),
        ),
      );
      _countdown = Timer.periodic(
        const Duration(seconds: 1),
        (_) => add(const _RideRequestTicked()),
      );
    }
  }

  void _onTicked(_RideRequestTicked event, Emitter<RideRequestState> emit) {
    final currentState = state;
    if (currentState is! RideRequestOffered) return;

    final request = currentState.offer.request;
    // No answer in time: the request goes to another driver.
    if (request.isExpired(DateTime.now())) {
      _countdown?.cancel();
      emit(const RideRequestWaiting());
      return;
    }
    emit(
      currentState.copyWith(secondsLeft: request.secondsLeft(DateTime.now())),
    );
  }

  Future<void> _onAccepted(
    RideRequestAccepted event,
    Emitter<RideRequestState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RideRequestOffered || currentState.isResponding) {
      return;
    }

    emit(currentState.copyWith(isResponding: true));
    final result = await _acceptRideRequestUseCase(
      currentState.offer.request.id,
    );
    switch (result) {
      case Ok(:final value):
        _stopWatching();
        emit(RideRequestTaken(ride: value));
      case Error(:final error):
        emit(
          RideRequestOffered(
            offer: currentState.offer,
            secondsLeft: currentState.secondsLeft,
            failureMessage: error.message,
          ),
        );
    }
  }

  Future<void> _onDeclined(
    RideRequestDeclined event,
    Emitter<RideRequestState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RideRequestOffered || currentState.isResponding) {
      return;
    }

    emit(currentState.copyWith(isResponding: true));
    await _declineRideRequestUseCase(currentState.offer.request.id);
    // Even if the refusal is lost, the request expires on its own.
    _countdown?.cancel();
    emit(const RideRequestWaiting());
  }

  void _stopWatching() {
    unawaited(_requests?.cancel());
    _requests = null;
    _countdown?.cancel();
  }

  @override
  Future<void> close() {
    _stopWatching();
    return super.close();
  }
}

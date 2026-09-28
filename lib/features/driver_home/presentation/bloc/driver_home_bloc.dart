import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_home.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_home_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/set_online_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/set_receives_bookings_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/share_driver_position_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_driver_connection_usecase.dart';

part 'driver_home_event.dart';
part 'driver_home_state.dart';

class DriverHomeBloc extends Bloc<DriverHomeEvent, DriverHomeState> {
  DriverHomeBloc({
    required LoadDriverHomeUseCase loadDriverHomeUseCase,
    required SetOnlineUseCase setOnlineUseCase,
    required SetReceivesBookingsUseCase setReceivesBookingsUseCase,
    required ShareDriverPositionUseCase shareDriverPositionUseCase,
    required WatchDriverConnectionUseCase watchDriverConnectionUseCase,
  }) : _loadDriverHomeUseCase = loadDriverHomeUseCase,
       _setOnlineUseCase = setOnlineUseCase,
       _setReceivesBookingsUseCase = setReceivesBookingsUseCase,
       _shareDriverPositionUseCase = shareDriverPositionUseCase,
       _watchDriverConnectionUseCase = watchDriverConnectionUseCase,
       super(const DriverHomeLoading()) {
    on<DriverHomeStarted>(_onStarted);
    on<DriverOnlineToggled>(_onOnlineToggled);
    on<DriverConnectionChanged>(_onConnectionChanged);
    on<DriverBookingsToggled>(_onBookingsToggled);
  }

  final LoadDriverHomeUseCase _loadDriverHomeUseCase;
  final SetOnlineUseCase _setOnlineUseCase;
  final SetReceivesBookingsUseCase _setReceivesBookingsUseCase;
  final ShareDriverPositionUseCase _shareDriverPositionUseCase;
  final WatchDriverConnectionUseCase _watchDriverConnectionUseCase;

  // While the driver is online: sends their position, and follows the
  // connection to warn them when passengers no longer see them.
  StreamSubscription<Result<void>>? _positionSharing;
  StreamSubscription<bool>? _connection;

  Future<void> _onStarted(
    DriverHomeStarted event,
    Emitter<DriverHomeState> emit,
  ) async {
    emit(const DriverHomeLoading());
    switch (await _loadDriverHomeUseCase()) {
      case Ok(:final value):
        emit(DriverHomeReady(home: value));
      case Error(:final error):
        emit(DriverHomeFailure(message: error.message));
    }
  }

  Future<void> _onOnlineToggled(
    DriverOnlineToggled event,
    Emitter<DriverHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverHomeReady || currentState.isSwitchingOnline) {
      return;
    }

    emit(
      DriverHomeReady(
        home: currentState.home,
        isSwitchingOnline: true,
        isConnected: currentState.isConnected,
      ),
    );
    // Offline: stops sending before the entry is removed, so a late position
    // does not write it back.
    if (!event.isOnline) await _stopBeingOnline();
    final result = await _setOnlineUseCase(isOnline: event.isOnline);
    // Still online after a failed "Passer hors ligne": keep sending.
    if (event.isOnline == result is Ok) _startBeingOnline();
    final home = currentState.home;
    emit(
      switch (result) {
        Ok() => DriverHomeReady(
          home: home.withActivity(
            home.activity.withOnline(isOnline: event.isOnline),
          ),
        ),
        Error(:final error) => DriverHomeReady(
          home: home,
          switchFailureMessage: error.message,
          isConnected: currentState.isConnected,
        ),
      },
    );
  }

  void _onConnectionChanged(
    DriverConnectionChanged event,
    Emitter<DriverHomeState> emit,
  ) {
    final currentState = state;
    if (currentState is! DriverHomeReady) return;

    emit(
      DriverHomeReady(
        home: currentState.home,
        isSwitchingOnline: currentState.isSwitchingOnline,
        switchFailureMessage: currentState.switchFailureMessage,
        isConnected: event.isConnected,
      ),
    );
  }

  Future<void> _onBookingsToggled(
    DriverBookingsToggled event,
    Emitter<DriverHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverHomeReady) return;

    // The switch moves right away; it goes back if the change fails.
    final home = currentState.home;
    emit(
      DriverHomeReady(
        home: home.withActivity(
          home.activity.withReceivesBookings(
            receivesBookings: event.receivesBookings,
          ),
        ),
        isConnected: currentState.isConnected,
      ),
    );
    final result = await _setReceivesBookingsUseCase(
      receivesBookings: event.receivesBookings,
    );
    if (result case Error()) emit(currentState);
  }

  // A failed position is simply retried with the next one.
  void _startBeingOnline() {
    _positionSharing ??= _shareDriverPositionUseCase().listen((_) {});
    _connection ??= _watchDriverConnectionUseCase().listen(
      (isConnected) => add(DriverConnectionChanged(isConnected: isConnected)),
    );
  }

  Future<void> _stopBeingOnline() async {
    await _positionSharing?.cancel();
    _positionSharing = null;
    await _connection?.cancel();
    _connection = null;
  }

  @override
  Future<void> close() async {
    await _stopBeingOnline();
    return super.close();
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/usecases/watch_connection_usecase.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_home.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_home_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/set_online_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/share_driver_position_usecase.dart';

part 'driver_home_event.dart';
part 'driver_home_state.dart';

class DriverHomeBloc extends Bloc<DriverHomeEvent, DriverHomeState> {
  DriverHomeBloc({
    required LoadDriverHomeUseCase loadDriverHomeUseCase,
    required SetOnlineUseCase setOnlineUseCase,
    required ShareDriverPositionUseCase shareDriverPositionUseCase,
    required WatchConnectionUseCase watchConnectionUseCase,
  }) : _loadDriverHomeUseCase = loadDriverHomeUseCase,
       _setOnlineUseCase = setOnlineUseCase,
       _shareDriverPositionUseCase = shareDriverPositionUseCase,
       _watchConnectionUseCase = watchConnectionUseCase,
       super(const DriverHomeLoading()) {
    on<DriverHomeStarted>(_onStarted);
    on<DriverOnlineToggled>(_onOnlineToggled);
    on<DriverConnectionChanged>(_onConnectionChanged);
  }

  final LoadDriverHomeUseCase _loadDriverHomeUseCase;
  final SetOnlineUseCase _setOnlineUseCase;
  final ShareDriverPositionUseCase _shareDriverPositionUseCase;
  final WatchConnectionUseCase _watchConnectionUseCase;

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

  // A failed position is simply retried with the next one.
  void _startBeingOnline() {
    _positionSharing ??= _shareDriverPositionUseCase().listen((_) {});
    _connection ??= _watchConnectionUseCase().listen(
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

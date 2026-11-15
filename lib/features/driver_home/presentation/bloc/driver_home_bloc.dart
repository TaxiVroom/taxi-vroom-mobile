import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/usecases/open_location_settings_usecase.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_home.dart';
import 'package:mobile/features/driver_home/domain/usecases/go_offline_to_sign_out_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_home_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/restore_driver_presence_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/set_online_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/share_driver_position_usecase.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_online_allowed_usecase.dart';

part 'driver_home_event.dart';
part 'driver_home_state.dart';

class DriverHomeBloc extends Bloc<DriverHomeEvent, DriverHomeState> {
  DriverHomeBloc({
    required LoadDriverHomeUseCase loadDriverHomeUseCase,
    required SetOnlineUseCase setOnlineUseCase,
    required ShareDriverPositionUseCase shareDriverPositionUseCase,
    required WatchOnlineAllowedUseCase watchOnlineAllowedUseCase,
    required OpenLocationSettingsUseCase openLocationSettingsUseCase,
    required RestoreDriverPresenceUseCase restoreDriverPresenceUseCase,
    required GoOfflineToSignOutUseCase goOfflineToSignOutUseCase,
  }) : _loadDriverHomeUseCase = loadDriverHomeUseCase,
       _restoreDriverPresenceUseCase = restoreDriverPresenceUseCase,
       _goOfflineToSignOutUseCase = goOfflineToSignOutUseCase,
       _openLocationSettingsUseCase = openLocationSettingsUseCase,
       _watchOnlineAllowedUseCase = watchOnlineAllowedUseCase,
       _setOnlineUseCase = setOnlineUseCase,
       _shareDriverPositionUseCase = shareDriverPositionUseCase,
       super(const DriverHomeLoading()) {
    on<DriverHomeStarted>(_onStarted);
    on<DriverLocationSettingsOpened>(
      (_, _) => _openLocationSettingsUseCase(),
    );
    on<DriverOnlineToggled>(_onOnlineToggled);
    on<_DriverTakenOfflineForDocuments>(_onTakenOfflineForDocuments);
    on<DriverPresenceRestored>(_onPresenceRestored);
    on<DriverSignOutRequested>(_onSignOutRequested);
  }

  final RestoreDriverPresenceUseCase _restoreDriverPresenceUseCase;
  final GoOfflineToSignOutUseCase _goOfflineToSignOutUseCase;

  // Once per app start: later returns to the home must not run it again.
  bool _hasRestoredPresence = false;

  final LoadDriverHomeUseCase _loadDriverHomeUseCase;
  final SetOnlineUseCase _setOnlineUseCase;
  final ShareDriverPositionUseCase _shareDriverPositionUseCase;
  final WatchOnlineAllowedUseCase _watchOnlineAllowedUseCase;
  final OpenLocationSettingsUseCase _openLocationSettingsUseCase;

  // While the driver is online: sends their position.
  StreamSubscription<Result<void>>? _positionSharing;
  StreamSubscription<void>? _permission;

  Future<void> _onStarted(
    DriverHomeStarted event,
    Emitter<DriverHomeState> emit,
  ) async {
    emit(const DriverHomeLoading());
    switch (await _loadDriverHomeUseCase()) {
      case Ok(:final value):
        emit(DriverHomeReady(home: value));
      case Error(:final error):
        emit(
          DriverHomeFailure(
            message: error.message,
            needsSettings: error is LocationSettingsFailure,
          ),
        );
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
          home: home.withOnline(isOnline: event.isOnline),
        ),
        Error(:final DocumentsBlockingFailure error) => DriverHomeReady(
          home: home,
          isBlockedByDocuments: true,
        ),
        Error(:final error) => DriverHomeReady(
          home: home,
          switchFailureMessage: error.message,
        ),
      },
    );
  }

  // Waits for the home: its position is what going online needs.
  Future<void> _onPresenceRestored(
    DriverPresenceRestored event,
    Emitter<DriverHomeState> emit,
  ) async {
    final currentState = state;
    if (_hasRestoredPresence || currentState is DriverHomeLoading) return;
    _hasRestoredPresence = true;
    // No position: offline whatever the entry says, the home tells why.
    if (currentState is! DriverHomeReady) {
      await _restoreDriverPresenceUseCase(mayGoOnline: false);
      return;
    }
    // Already back online with a resumed ride.
    if (currentState.home.isOnline) return;

    final home = currentState.home;
    emit(DriverHomeReady(home: home, isRestoringPresence: true));
    final result = await _restoreDriverPresenceUseCase(mayGoOnline: true);
    if (result case Ok(value: true)) _startBeingOnline();
    emit(
      switch (result) {
        Ok(value: true) => DriverHomeReady(
          home: home.withOnline(isOnline: true),
        ),
        Ok() => DriverHomeReady(home: home),
        Error(error: DocumentsBlockingFailure()) => DriverHomeReady(
          home: home,
          isBlockedByDocuments: true,
        ),
        Error(:final error) => DriverHomeReady(
          home: home,
          switchFailureMessage: error.message,
        ),
      },
    );
  }

  // Positions stop first, so a late one does not write the entry back; they
  // start again if the driver has to stay online.
  Future<void> _onSignOutRequested(
    DriverSignOutRequested event,
    Emitter<DriverHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverHomeReady || currentState.isSigningOut) return;

    final home = currentState.home;
    // Offline: nothing left for the passengers, sign out at once.
    if (!home.isOnline) {
      emit(DriverHomeReady(home: home, isReadyToSignOut: true));
      return;
    }
    emit(DriverHomeReady(home: home, isSigningOut: true));
    await _stopBeingOnline();
    switch (await _goOfflineToSignOutUseCase()) {
      case Ok():
        emit(
          DriverHomeReady(
            home: home.withOnline(isOnline: false),
            isReadyToSignOut: true,
          ),
        );
      case Error(:final error):
        _startBeingOnline();
        emit(
          DriverHomeReady(home: home, signOutFailureMessage: error.message),
        );
    }
  }

  // A failed position is simply retried with the next one.
  void _startBeingOnline() {
    _positionSharing ??= _shareDriverPositionUseCase().listen((_) {});
    _permission ??= _watchOnlineAllowedUseCase().listen(
      (_) => add(const _DriverTakenOfflineForDocuments()),
    );
  }

  // The server removed the presence: the app goes offline too, and the
  // documents screen says why.
  Future<void> _onTakenOfflineForDocuments(
    _DriverTakenOfflineForDocuments event,
    Emitter<DriverHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DriverHomeReady) return;
    await _stopBeingOnline();
    await _setOnlineUseCase(isOnline: false);
    final home = currentState.home;
    emit(
      DriverHomeReady(
        home: home.withOnline(isOnline: false),
        isBlockedByDocuments: true,
      ),
    );
  }

  Future<void> _stopBeingOnline() async {
    await _positionSharing?.cancel();
    _positionSharing = null;
    await _permission?.cancel();
    _permission = null;
  }

  @override
  Future<void> close() async {
    await _stopBeingOnline();
    return super.close();
  }
}

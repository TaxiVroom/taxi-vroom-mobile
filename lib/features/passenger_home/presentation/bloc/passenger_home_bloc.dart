import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_home.dart';
import 'package:mobile/features/passenger_home/domain/entities/place.dart';
import 'package:mobile/features/passenger_home/domain/entities/saved_place.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_passenger_home_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/refresh_pickup_position_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/watch_nearby_taxis_usecase.dart';

part 'passenger_home_event.dart';
part 'passenger_home_state.dart';

class PassengerHomeBloc extends Bloc<PassengerHomeEvent, PassengerHomeState> {
  PassengerHomeBloc({
    required LoadPassengerHomeUseCase loadPassengerHomeUseCase,
    required WatchNearbyTaxisUseCase watchNearbyTaxisUseCase,
    required RefreshPickupPositionUseCase refreshPickupPositionUseCase,
  }) : _loadPassengerHomeUseCase = loadPassengerHomeUseCase,
       _watchNearbyTaxisUseCase = watchNearbyTaxisUseCase,
       _refreshPickupPositionUseCase = refreshPickupPositionUseCase,
       super(const PassengerHomeLoading()) {
    on<PassengerHomeStarted>(_onStarted);
    on<PassengerPositionRefreshed>(_onPositionRefreshed);
    on<PassengerSavedPlaceStored>(_onSavedPlaceStored);
    on<PassengerSavedPlaceRemoved>(_onSavedPlaceRemoved);
  }

  final LoadPassengerHomeUseCase _loadPassengerHomeUseCase;
  final WatchNearbyTaxisUseCase _watchNearbyTaxisUseCase;
  final RefreshPickupPositionUseCase _refreshPickupPositionUseCase;

  Future<void> _onStarted(
    PassengerHomeStarted event,
    Emitter<PassengerHomeState> emit,
  ) async {
    emit(const PassengerHomeLoading());
    switch (await _loadPassengerHomeUseCase()) {
      case Ok(value: final home):
        emit(PassengerHomeReady(home: home));
        await emit.forEach<Result<List<NearbyTaxi>>>(
          _watchNearbyTaxisUseCase(around: home.position),
          // Without an update, the taxis last seen stay on the map. The home
          // is the state's: a saved place may have changed it since.
          onData: (result) => switch ((result, state)) {
            (Ok(value: final nearbyTaxis), final PassengerHomeReady ready) =>
              ready.copyWith(
                nearbyTaxis: nearbyTaxis,
                locationFailure: ready.locationFailure,
              ),
            _ => state,
          },
        );
      case Error(:final error):
        emit(PassengerHomeFailure(message: error.message));
    }
  }

  // The passenger leaves the home to order: "Position actuelle" is read again
  // (unless a pickup was chosen), with a loader until the answer. The
  // position of the nearby taxis' search is not moved here: it follows the
  // phone by itself.
  Future<void> _onPositionRefreshed(
    PassengerPositionRefreshed event,
    Emitter<PassengerHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PassengerHomeReady) return;

    emit(currentState.copyWith(isLocating: true));
    final result = await _refreshPickupPositionUseCase(
      home: currentState.home,
      chosen: event.chosen,
    );
    // A saved place may have changed the home while the position was read.
    final latest = switch (state) {
      final PassengerHomeReady ready => ready,
      _ => currentState,
    };
    switch (result) {
      case Ok(value: final home):
        emit(
          latest.copyWith(
            home: latest.home.withPosition(home.position),
            isLocating: false,
          ),
        );
      case Error(:final error):
        emit(latest.copyWith(isLocating: false, locationFailure: error));
    }
  }

  // The shortcut shows it at once, without reloading the home.
  void _onSavedPlaceStored(
    PassengerSavedPlaceStored event,
    Emitter<PassengerHomeState> emit,
  ) {
    _emitHome(emit, (home) => home.withSavedPlace(event.place));
  }

  void _onSavedPlaceRemoved(
    PassengerSavedPlaceRemoved event,
    Emitter<PassengerHomeState> emit,
  ) {
    _emitHome(emit, (home) => home.withoutSavedPlace(event.kind));
  }

  void _emitHome(
    Emitter<PassengerHomeState> emit,
    PassengerHome Function(PassengerHome home) change,
  ) {
    final currentState = state;
    if (currentState is! PassengerHomeReady) return;

    emit(currentState.copyWith(home: change(currentState.home)));
  }
}

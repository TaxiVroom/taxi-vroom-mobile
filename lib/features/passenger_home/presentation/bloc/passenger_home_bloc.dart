import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/usecases/watch_connection_usecase.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/passenger_home/domain/entities/nearby_taxi.dart';
import 'package:mobile/features/passenger_home/domain/entities/passenger_home.dart';
import 'package:mobile/features/passenger_home/domain/usecases/load_passenger_home_usecase.dart';
import 'package:mobile/features/passenger_home/domain/usecases/watch_nearby_taxis_usecase.dart';

part 'passenger_home_event.dart';
part 'passenger_home_state.dart';

class PassengerHomeBloc extends Bloc<PassengerHomeEvent, PassengerHomeState> {
  PassengerHomeBloc({
    required LoadPassengerHomeUseCase loadPassengerHomeUseCase,
    required WatchNearbyTaxisUseCase watchNearbyTaxisUseCase,
    required WatchConnectionUseCase watchConnectionUseCase,
  }) : _loadPassengerHomeUseCase = loadPassengerHomeUseCase,
       _watchNearbyTaxisUseCase = watchNearbyTaxisUseCase,
       _watchConnectionUseCase = watchConnectionUseCase,
       super(const PassengerHomeLoading()) {
    on<PassengerHomeStarted>(_onStarted);
    on<PassengerConnectionChanged>(_onConnectionChanged);
  }

  final LoadPassengerHomeUseCase _loadPassengerHomeUseCase;
  final WatchNearbyTaxisUseCase _watchNearbyTaxisUseCase;
  final WatchConnectionUseCase _watchConnectionUseCase;

  // Warns the passenger when the taxis shown are no longer live.
  StreamSubscription<bool>? _connection;

  Future<void> _onStarted(
    PassengerHomeStarted event,
    Emitter<PassengerHomeState> emit,
  ) async {
    emit(const PassengerHomeLoading());
    switch (await _loadPassengerHomeUseCase()) {
      case Ok(value: final home):
        emit(PassengerHomeReady(home: home));
        _connection ??= _watchConnectionUseCase().listen(
          (isConnected) =>
              add(PassengerConnectionChanged(isConnected: isConnected)),
        );
        await emit.forEach<Result<List<NearbyTaxi>>>(
          _watchNearbyTaxisUseCase(around: home.position),
          // Without an update, the taxis last seen stay on the map.
          onData: (result) => switch ((result, state)) {
            (
              Ok(value: final nearbyTaxis),
              PassengerHomeReady(:final isConnected),
            ) =>
              PassengerHomeReady(
                home: home,
                nearbyTaxis: nearbyTaxis,
                isConnected: isConnected,
              ),
            _ => state,
          },
        );
      case Error(:final error):
        emit(PassengerHomeFailure(message: error.message));
    }
  }

  void _onConnectionChanged(
    PassengerConnectionChanged event,
    Emitter<PassengerHomeState> emit,
  ) {
    final currentState = state;
    if (currentState is! PassengerHomeReady) return;

    emit(
      PassengerHomeReady(
        home: currentState.home,
        nearbyTaxis: currentState.nearbyTaxis,
        isConnected: event.isConnected,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _connection?.cancel();
    return super.close();
  }
}

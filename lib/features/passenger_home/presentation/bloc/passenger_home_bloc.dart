import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
  }) : _loadPassengerHomeUseCase = loadPassengerHomeUseCase,
       _watchNearbyTaxisUseCase = watchNearbyTaxisUseCase,
       super(const PassengerHomeLoading()) {
    on<PassengerHomeStarted>(_onStarted);
  }

  final LoadPassengerHomeUseCase _loadPassengerHomeUseCase;
  final WatchNearbyTaxisUseCase _watchNearbyTaxisUseCase;

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
          // Without an update, the taxis last seen stay on the map.
          onData: (result) => switch (result) {
            Ok(value: final nearbyTaxis) => PassengerHomeReady(
              home: home,
              nearbyTaxis: nearbyTaxis,
            ),
            Error() => state,
          },
        );
      case Error(:final error):
        emit(PassengerHomeFailure(message: error.message));
    }
  }
}

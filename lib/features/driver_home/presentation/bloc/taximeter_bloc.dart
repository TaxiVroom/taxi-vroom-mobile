import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/meter_reading.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_taximeter_usecase.dart';

part 'taximeter_event.dart';
part 'taximeter_state.dart';

/// The taxi's meter mirrored during the ride (mockup screen 7).
class TaximeterBloc extends Bloc<TaximeterEvent, TaximeterState> {
  TaximeterBloc({required WatchTaximeterUseCase watchTaximeterUseCase})
    : _watchTaximeterUseCase = watchTaximeterUseCase,
      super(const TaximeterWaiting()) {
    on<TaximeterStarted>(_onStarted);
  }

  final WatchTaximeterUseCase _watchTaximeterUseCase;

  Future<void> _onStarted(
    TaximeterStarted event,
    Emitter<TaximeterState> emit,
  ) {
    return emit.forEach<Result<MeterReading>>(
      _watchTaximeterUseCase(),
      onData: (result) => switch (result) {
        Ok(:final value) => TaximeterRunning(reading: value),
        Error(:final error) => TaximeterFailure(message: error.message),
      },
    );
  }
}

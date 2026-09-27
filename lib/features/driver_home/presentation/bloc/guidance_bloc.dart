import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/coordinates.dart';
import 'package:mobile/core/domain/entities/guidance.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/usecases/watch_guidance_usecase.dart';

part 'guidance_event.dart';
part 'guidance_state.dart';

/// Turn-by-turn guidance to a place: the passenger, then the destination.
class GuidanceBloc extends Bloc<GuidanceEvent, GuidanceState> {
  GuidanceBloc({required WatchGuidanceUseCase watchGuidanceUseCase})
    : _watchGuidanceUseCase = watchGuidanceUseCase,
      super(const GuidanceLoading()) {
    on<GuidanceStarted>(_onStarted);
  }

  final WatchGuidanceUseCase _watchGuidanceUseCase;

  Future<void> _onStarted(GuidanceStarted event, Emitter<GuidanceState> emit) {
    emit(const GuidanceLoading());
    return emit.forEach<Result<Guidance>>(
      _watchGuidanceUseCase(to: event.to, from: event.from),
      onData: (result) => switch (result) {
        Ok(:final value) => GuidanceReady(guidance: value),
        Error(:final error) => GuidanceFailure(message: error.message),
      },
    );
  }
}

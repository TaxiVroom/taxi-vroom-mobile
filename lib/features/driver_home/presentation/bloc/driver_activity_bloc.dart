import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/driver_activity.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_driver_activity_usecase.dart';

part 'driver_activity_event.dart';
part 'driver_activity_state.dart';

/// The pill and the three cards of the "Conduire" tab. Spec
/// taxi-vroom-api/docs/specs/gains-reels.md.
class DriverActivityBloc
    extends Bloc<DriverActivityEvent, DriverActivityState> {
  DriverActivityBloc({
    required LoadDriverActivityUseCase loadDriverActivityUseCase,
  }) : _loadDriverActivityUseCase = loadDriverActivityUseCase,
       super(const DriverActivityLoading()) {
    on<DriverActivityRequested>(_onRequested);
  }

  final LoadDriverActivityUseCase _loadDriverActivityUseCase;

  // The small loaders show each time the API is asked.
  Future<void> _onRequested(
    DriverActivityRequested event,
    Emitter<DriverActivityState> emit,
  ) async {
    emit(const DriverActivityLoading());
    switch (await _loadDriverActivityUseCase()) {
      case Ok(:final value):
        emit(DriverActivityReady(activity: value));
      case Error():
        emit(const DriverActivityFailure());
    }
  }
}

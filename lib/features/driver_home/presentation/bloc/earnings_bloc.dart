import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/weekly_earnings.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_weekly_earnings_usecase.dart';

part 'earnings_event.dart';
part 'earnings_state.dart';

/// Mockup screen 10: the "Gains" tab.
class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  EarningsBloc({required LoadWeeklyEarningsUseCase loadWeeklyEarningsUseCase})
    : _loadWeeklyEarningsUseCase = loadWeeklyEarningsUseCase,
      super(const EarningsLoading()) {
    on<EarningsRequested>(_onRequested);
  }

  final LoadWeeklyEarningsUseCase _loadWeeklyEarningsUseCase;

  Future<void> _onRequested(
    EarningsRequested event,
    Emitter<EarningsState> emit,
  ) async {
    // A refresh keeps the figures on screen instead of a loader.
    if (state is! EarningsReady) emit(const EarningsLoading());
    switch (await _loadWeeklyEarningsUseCase()) {
      case Ok(:final value):
        emit(EarningsReady(earnings: value));
      case Error(:final error):
        emit(EarningsFailure(message: error.message));
    }
  }
}

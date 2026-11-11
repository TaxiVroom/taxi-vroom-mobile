import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/driver_home/domain/entities/earnings.dart';
import 'package:mobile/features/driver_home/domain/usecases/load_earnings_usecase.dart';

part 'earnings_event.dart';
part 'earnings_state.dart';

/// The "Gains" tab: spec taxi-vroom-api/docs/specs/gains-du-chauffeur.md.
class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  EarningsBloc({required LoadEarningsUseCase loadEarningsUseCase})
    : _loadEarningsUseCase = loadEarningsUseCase,
      super(const EarningsLoading(period: EarningsPeriod.week)) {
    on<EarningsRequested>(_onRequested);
    on<EarningsPeriodChosen>(_onPeriodChosen);
    on<EarningsDayTapped>(_onDayTapped);
  }

  final LoadEarningsUseCase _loadEarningsUseCase;

  Future<void> _onRequested(
    EarningsRequested event,
    Emitter<EarningsState> emit,
  ) async {
    // The loader shows each time the API is asked, and the tapped bar is
    // forgotten: the figures may have changed.
    final period = state.period;
    emit(EarningsLoading(period: period));
    return _load(period, emit);
  }

  Future<void> _onPeriodChosen(
    EarningsPeriodChosen event,
    Emitter<EarningsState> emit,
  ) async {
    if (event.period == state.period) return;
    emit(EarningsLoading(period: event.period));
    return _load(event.period, emit);
  }

  void _onDayTapped(EarningsDayTapped event, Emitter<EarningsState> emit) {
    final current = state;
    if (current is! EarningsReady) return;
    emit(
      EarningsReady(
        earnings: current.earnings,
        pickedDay: current.pickedDay == event.day ? null : event.day,
      ),
    );
  }

  Future<void> _load(
    EarningsPeriod period,
    Emitter<EarningsState> emit,
  ) async {
    final result = await _loadEarningsUseCase(period);
    // Another period was chosen meanwhile: only the last one shows.
    if (state.period != period) return;
    switch (result) {
      case Ok(:final value):
        emit(EarningsReady(earnings: value));
      case Error(:final error):
        emit(EarningsFailure(period: period, message: error.message));
    }
  }
}

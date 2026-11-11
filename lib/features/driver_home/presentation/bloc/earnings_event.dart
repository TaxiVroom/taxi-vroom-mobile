part of 'earnings_bloc.dart';

sealed class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object?> get props => [];
}

// The tab is shown, or the driver taps "Réessayer": the same period again.
final class EarningsRequested extends EarningsEvent {
  const EarningsRequested();
}

// The driver picks "Aujourd'hui", "Cette semaine" or "Ce mois".
final class EarningsPeriodChosen extends EarningsEvent {
  const EarningsPeriodChosen(this.period);

  final EarningsPeriod period;

  @override
  List<Object?> get props => [period];
}

// The driver taps a bar of the chart: its amount shows, a second tap hides
// it.
final class EarningsDayTapped extends EarningsEvent {
  const EarningsDayTapped(this.day);

  final DateTime day;

  @override
  List<Object?> get props => [day];
}

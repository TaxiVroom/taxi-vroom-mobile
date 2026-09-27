part of 'earnings_bloc.dart';

sealed class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object?> get props => [];
}

// The tab is shown, or the driver taps "Réessayer".
final class EarningsRequested extends EarningsEvent {
  const EarningsRequested();
}

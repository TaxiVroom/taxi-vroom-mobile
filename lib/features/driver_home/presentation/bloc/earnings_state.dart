part of 'earnings_bloc.dart';

sealed class EarningsState extends Equatable {
  const EarningsState();

  // The period on the button, kept when the driver leaves the tab.
  EarningsPeriod get period;

  @override
  List<Object?> get props => [period];
}

final class EarningsLoading extends EarningsState {
  const EarningsLoading({required this.period});

  @override
  final EarningsPeriod period;
}

final class EarningsReady extends EarningsState {
  const EarningsReady({required this.earnings, this.pickedDay});

  final Earnings earnings;

  // The bar the driver tapped, its amount shown above the chart.
  final DateTime? pickedDay;

  @override
  EarningsPeriod get period => earnings.period;

  @override
  List<Object?> get props => [earnings, pickedDay];
}

final class EarningsFailure extends EarningsState {
  const EarningsFailure({required this.period, required this.message});

  @override
  final EarningsPeriod period;

  final String message;

  @override
  List<Object?> get props => [period, message];
}

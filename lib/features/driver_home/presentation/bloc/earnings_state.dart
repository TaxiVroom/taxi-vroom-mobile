part of 'earnings_bloc.dart';

sealed class EarningsState extends Equatable {
  const EarningsState();

  @override
  List<Object?> get props => [];
}

final class EarningsLoading extends EarningsState {
  const EarningsLoading();
}

final class EarningsReady extends EarningsState {
  const EarningsReady({required this.earnings});

  final WeeklyEarnings earnings;

  @override
  List<Object?> get props => [earnings];
}

final class EarningsFailure extends EarningsState {
  const EarningsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

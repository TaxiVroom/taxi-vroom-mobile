part of 'account_bloc.dart';

sealed class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

final class AccountLoading extends AccountState {
  const AccountLoading();
}

final class AccountReady extends AccountState {
  const AccountReady({required this.account});

  final PassengerAccount account;

  @override
  List<Object?> get props => [account];
}

final class AccountFailure extends AccountState {
  const AccountFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

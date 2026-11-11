part of 'driver_account_bloc.dart';

sealed class DriverAccountState extends Equatable {
  const DriverAccountState();

  @override
  List<Object?> get props => [];
}

final class DriverAccountLoading extends DriverAccountState {
  const DriverAccountLoading();
}

final class DriverAccountReady extends DriverAccountState {
  const DriverAccountReady({required this.account});

  final DriverAccount account;

  @override
  List<Object?> get props => [account];
}

final class DriverAccountFailure extends DriverAccountState {
  const DriverAccountFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

part of 'driver_home_bloc.dart';

sealed class DriverHomeState extends Equatable {
  const DriverHomeState();

  @override
  List<Object?> get props => [];
}

final class DriverHomeLoading extends DriverHomeState {
  const DriverHomeLoading();
}

final class DriverHomeReady extends DriverHomeState {
  const DriverHomeReady({
    required this.home,
    this.isSwitchingOnline = false,
    this.switchFailureMessage,
  });

  final DriverHome home;

  // Going online or offline is in progress.
  final bool isSwitchingOnline;

  // Why the last online/offline switch failed.
  final String? switchFailureMessage;

  @override
  List<Object?> get props => [home, isSwitchingOnline, switchFailureMessage];
}

final class DriverHomeFailure extends DriverHomeState {
  const DriverHomeFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

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
    this.isConnected = true,
  });

  final DriverHome home;

  // Going online or offline is in progress.
  final bool isSwitchingOnline;

  // Why the last online/offline switch failed.
  final String? switchFailureMessage;

  // Online but without connection: passengers no longer see the driver.
  final bool isConnected;

  @override
  List<Object?> get props => [
    home,
    isSwitchingOnline,
    switchFailureMessage,
    isConnected,
  ];
}

final class DriverHomeFailure extends DriverHomeState {
  const DriverHomeFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

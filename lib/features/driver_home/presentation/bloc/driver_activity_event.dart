part of 'driver_activity_bloc.dart';

sealed class DriverActivityEvent extends Equatable {
  const DriverActivityEvent();

  @override
  List<Object?> get props => [];
}

// The home opens, the driver comes back to "Conduire", or a ride ends.
final class DriverActivityRequested extends DriverActivityEvent {
  const DriverActivityRequested();
}

part of 'driver_activity_bloc.dart';

sealed class DriverActivityState extends Equatable {
  const DriverActivityState();

  @override
  List<Object?> get props => [];
}

final class DriverActivityLoading extends DriverActivityState {
  const DriverActivityLoading();
}

final class DriverActivityReady extends DriverActivityState {
  const DriverActivityReady({required this.activity});

  final DriverActivity activity;

  @override
  List<Object?> get props => [activity];
}

// "–" instead of the figures; the driver can still go online. Asked again
// at the next arrival on "Conduire" or the next ride's end.
final class DriverActivityFailure extends DriverActivityState {
  const DriverActivityFailure();
}

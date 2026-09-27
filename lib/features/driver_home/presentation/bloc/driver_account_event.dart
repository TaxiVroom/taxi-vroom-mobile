part of 'driver_account_bloc.dart';

sealed class DriverAccountEvent extends Equatable {
  const DriverAccountEvent();

  @override
  List<Object?> get props => [];
}

// The tab is shown, or the driver taps "Réessayer".
final class DriverAccountRequested extends DriverAccountEvent {
  const DriverAccountRequested();
}

final class DriverAccountNotificationsToggled extends DriverAccountEvent {
  const DriverAccountNotificationsToggled({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

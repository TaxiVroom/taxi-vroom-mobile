part of 'driver_account_bloc.dart';

sealed class DriverAccountEvent extends Equatable {
  const DriverAccountEvent();

  @override
  List<Object?> get props => [];
}

// The home is shown, the driver opens the tab, or taps "Réessayer".
final class DriverAccountRequested extends DriverAccountEvent {
  const DriverAccountRequested();
}

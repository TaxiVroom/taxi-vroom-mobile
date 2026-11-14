part of 'connectivity_bloc.dart';

sealed class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object?> get props => [];
}

// The signed-in app starts following the device's connection.
final class ConnectivityWatchStarted extends ConnectivityEvent {
  const ConnectivityWatchStarted();
}

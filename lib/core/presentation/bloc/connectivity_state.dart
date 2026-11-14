part of 'connectivity_bloc.dart';

final class ConnectivityState extends Equatable {
  // Connected until Firebase says otherwise: no banner flashes at startup.
  const ConnectivityState({this.isConnected = true});

  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}

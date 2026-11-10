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
    this.isBlockedByDocuments = false,
  });

  final DriverHome home;

  // Going online or offline is in progress.
  final bool isSwitchingOnline;

  // Why the last online/offline switch failed.
  final String? switchFailureMessage;

  // Online but without connection: passengers no longer see the driver.
  final bool isConnected;

  // "Passer en ligne" refused: a document expired or is missing. The
  // documents screen opens. Spec
  // taxi-vroom-api/docs/specs/documents-du-chauffeur.md, point 8.
  final bool isBlockedByDocuments;

  @override
  List<Object?> get props => [
    home,
    isSwitchingOnline,
    switchFailureMessage,
    isConnected,
    isBlockedByDocuments,
  ];
}

final class DriverHomeFailure extends DriverHomeState {
  const DriverHomeFailure({required this.message, this.needsSettings = false});

  final String message;

  // The location was refused for good: "Ouvrir les réglages" is offered.
  final bool needsSettings;

  @override
  List<Object?> get props => [message, needsSettings];
}

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
    this.isBlockedByDocuments = false,
    this.isRestoringPresence = false,
    this.isSigningOut = false,
    this.isReadyToSignOut = false,
    this.signOutFailureMessage,
  });

  final DriverHome home;

  // At start, the entry left in Firebase is being checked: a full-screen
  // loader, nothing to tap.
  final bool isRestoringPresence;

  // "Se déconnecter" while online: going offline first.
  final bool isSigningOut;

  // Offline for good: the sign-out may go on. Once.
  final bool isReadyToSignOut;

  // Why "Se déconnecter" was refused (no network while online).
  final String? signOutFailureMessage;

  // Going online or offline is in progress.
  final bool isSwitchingOnline;

  // Why the last online/offline switch failed.
  final String? switchFailureMessage;

  // "Passer en ligne" refused: a document expired or is missing. The
  // documents screen opens. Spec
  // taxi-vroom-api/docs/specs/documents-du-chauffeur.md, point 8.
  final bool isBlockedByDocuments;

  @override
  List<Object?> get props => [
    home,
    isSwitchingOnline,
    switchFailureMessage,
    isBlockedByDocuments,
    isRestoringPresence,
    isSigningOut,
    isReadyToSignOut,
    signOutFailureMessage,
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

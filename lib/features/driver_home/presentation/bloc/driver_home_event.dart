part of 'driver_home_bloc.dart';

sealed class DriverHomeEvent extends Equatable {
  const DriverHomeEvent();

  @override
  List<Object?> get props => [];
}

// The home screen is shown, or the driver taps "Réessayer".
final class DriverHomeStarted extends DriverHomeEvent {
  const DriverHomeStarted();
}

// "Ouvrir les réglages", after the location was refused for good.
final class DriverLocationSettingsOpened extends DriverHomeEvent {
  const DriverLocationSettingsOpened();
}

// "Passer en ligne" / "Passer hors ligne".
final class DriverOnlineToggled extends DriverHomeEvent {
  const DriverOnlineToggled({required this.isOnline});

  final bool isOnline;

  @override
  List<Object?> get props => [isOnline];
}

// The app's start is settled (no ride to resume): the driver's entry left in
// Firebase puts them back online, or is removed. Spec
// taxi-vroom-api/docs/specs/presence-du-chauffeur-au-demarrage.md.
final class DriverPresenceRestored extends DriverHomeEvent {
  const DriverPresenceRestored();
}

// "Se déconnecter" while online: offline first, for good.
final class DriverSignOutRequested extends DriverHomeEvent {
  const DriverSignOutRequested();
}

// While online, the server took the driver offline for a document.
final class _DriverTakenOfflineForDocuments extends DriverHomeEvent {
  const _DriverTakenOfflineForDocuments();
}

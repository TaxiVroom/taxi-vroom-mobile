part of 'notification_permission_bloc.dart';

// Why the app needs its notifications at that moment: it tells the message
// shown when they are permanently denied.
enum NotificationNeed {
  // The passenger ordered or booked a taxi.
  rideUpdates,
  // The driver went online.
  rideRequests,
  // The driver accepted a booking.
  bookingReminder,
  // The driver sent their documents and waits for the admin.
  registrationReview,
}

sealed class NotificationPermissionEvent extends Equatable {
  const NotificationPermissionEvent();

  @override
  List<Object?> get props => [];
}

// After an action that needs the notifications: asks for them if missing.
final class NotificationPermissionChecked extends NotificationPermissionEvent {
  const NotificationPermissionChecked({required this.need});

  final NotificationNeed need;

  @override
  List<Object?> get props => [need];
}

// The account tab is shown: reads the permission, asks nothing.
final class NotificationPermissionRead extends NotificationPermissionEvent {
  const NotificationPermissionRead();
}

// "Activer" in the account tab: the system dialog if it can still show,
// otherwise the phone's settings.
final class NotificationPermissionEnabled extends NotificationPermissionEvent {
  const NotificationPermissionEnabled();
}

// "Réglages" on the message shown after a permanent denial, or "Désactiver"
// on the account tab.
final class NotificationSettingsOpened extends NotificationPermissionEvent {
  const NotificationSettingsOpened();
}

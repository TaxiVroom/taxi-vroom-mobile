// Whether the phone shows the app's notifications.
enum NotificationPermission {
  granted,
  // Not granted: the system may still ask the user.
  denied,
  // Only the phone's settings can grant it now: the system no longer asks.
  permanentlyDenied;

  // The app can only explain it, and lead to the phone's settings.
  bool get needsSettings => this == NotificationPermission.permanentlyDenied;
}

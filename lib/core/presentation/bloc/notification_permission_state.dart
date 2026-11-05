part of 'notification_permission_bloc.dart';

final class NotificationPermissionState extends Equatable {
  const NotificationPermissionState({
    this.permission,
    this.checks = 0,
    this.blockedFor,
  });

  // Null until read, or when the phone could not tell.
  final NotificationPermission? permission;

  // Counts the NotificationPermissionChecked answered: a screen waiting for
  // its check knows when it is done.
  final int checks;

  // After the last check: the need to explain, when only the settings can
  // allow the notifications now.
  final NotificationNeed? blockedFor;

  @override
  List<Object?> get props => [permission, checks, blockedFor];
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/notification_permission.dart';
import 'package:mobile/core/domain/usecases/enable_notifications_usecase.dart';
import 'package:mobile/core/domain/usecases/ensure_notification_permission_usecase.dart';
import 'package:mobile/core/domain/usecases/load_notification_permission_usecase.dart';
import 'package:mobile/core/domain/usecases/open_notification_settings_usecase.dart';
import 'package:mobile/core/utils/result.dart';

part 'notification_permission_event.dart';
part 'notification_permission_state.dart';

// The permission of the notifications, for every screen of both roles: told
// by the pages after an action that needs them, read by the account tabs.
// Spec permission-notifications.md.
class NotificationPermissionBloc
    extends Bloc<NotificationPermissionEvent, NotificationPermissionState> {
  NotificationPermissionBloc({
    required EnsureNotificationPermissionUseCase
    ensureNotificationPermissionUseCase,
    required LoadNotificationPermissionUseCase
    loadNotificationPermissionUseCase,
    required EnableNotificationsUseCase enableNotificationsUseCase,
    required OpenNotificationSettingsUseCase openNotificationSettingsUseCase,
  }) : _ensureNotificationPermissionUseCase =
           ensureNotificationPermissionUseCase,
       _loadNotificationPermissionUseCase = loadNotificationPermissionUseCase,
       _enableNotificationsUseCase = enableNotificationsUseCase,
       _openNotificationSettingsUseCase = openNotificationSettingsUseCase,
       super(const NotificationPermissionState()) {
    on<NotificationPermissionChecked>(_onChecked);
    on<NotificationPermissionRead>(_onRead);
    on<NotificationPermissionEnabled>(_onEnabled);
    on<NotificationSettingsOpened>(_onSettingsOpened);
  }

  final EnsureNotificationPermissionUseCase
  _ensureNotificationPermissionUseCase;
  final LoadNotificationPermissionUseCase _loadNotificationPermissionUseCase;
  final EnableNotificationsUseCase _enableNotificationsUseCase;
  final OpenNotificationSettingsUseCase _openNotificationSettingsUseCase;

  // A failed check shows nothing: the action already went through.
  Future<void> _onChecked(
    NotificationPermissionChecked event,
    Emitter<NotificationPermissionState> emit,
  ) async {
    final result = await _ensureNotificationPermissionUseCase();
    final permission = switch (result) {
      Ok(:final value) => value,
      Error() => state.permission,
    };
    emit(
      NotificationPermissionState(
        permission: permission,
        checks: state.checks + 1,
        blockedFor: (permission?.needsSettings ?? false) ? event.need : null,
      ),
    );
  }

  Future<void> _onRead(
    NotificationPermissionRead event,
    Emitter<NotificationPermissionState> emit,
  ) async {
    if (await _loadNotificationPermissionUseCase() case Ok(:final value)) {
      emit(_withPermission(value));
    }
  }

  Future<void> _onEnabled(
    NotificationPermissionEnabled event,
    Emitter<NotificationPermissionState> emit,
  ) async {
    if (await _enableNotificationsUseCase() case Ok(:final value)) {
      emit(_withPermission(value));
    }
  }

  Future<void> _onSettingsOpened(
    NotificationSettingsOpened event,
    Emitter<NotificationPermissionState> emit,
  ) async {
    await _openNotificationSettingsUseCase();
  }

  NotificationPermissionState _withPermission(
    NotificationPermission permission,
  ) => NotificationPermissionState(
    permission: permission,
    checks: state.checks,
    blockedFor: state.blockedFor,
  );
}

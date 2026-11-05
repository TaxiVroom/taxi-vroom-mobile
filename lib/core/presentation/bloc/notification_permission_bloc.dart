import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/domain/entities/notification_permission.dart';
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
    required OpenNotificationSettingsUseCase openNotificationSettingsUseCase,
  }) : _ensureNotificationPermissionUseCase =
           ensureNotificationPermissionUseCase,
       _loadNotificationPermissionUseCase = loadNotificationPermissionUseCase,
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
        blockedFor: permission == NotificationPermission.permanentlyDenied
            ? event.need
            : null,
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

  // In the account tab, the person asked for it: the settings open at once
  // when the dialog can no longer show.
  Future<void> _onEnabled(
    NotificationPermissionEnabled event,
    Emitter<NotificationPermissionState> emit,
  ) async {
    final result = await _ensureNotificationPermissionUseCase();
    if (result case Ok(:final value)) {
      emit(_withPermission(value));
      if (value == NotificationPermission.permanentlyDenied) {
        await _openNotificationSettingsUseCase();
      }
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

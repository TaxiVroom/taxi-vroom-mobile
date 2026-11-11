import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/entities/notification_permission.dart';
import 'package:mobile/core/presentation/bloc/notification_permission_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// The account tab's "Notifications" line, for both roles: what the phone
/// really allows, read when shown and again when the app comes back, e.g.
/// from the settings. The app cannot turn them on or off itself: "Activer"
/// asks the phone, "Désactiver" opens its settings.
class NotificationsRow extends StatefulWidget {
  const NotificationsRow({super.key});

  @override
  State<NotificationsRow> createState() => _NotificationsRowState();
}

class _NotificationsRowState extends State<NotificationsRow> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _read();
    _lifecycle = AppLifecycleListener(onResume: _read);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _read() => context.read<NotificationPermissionBloc>().add(
    const NotificationPermissionRead(),
  );

  @override
  Widget build(BuildContext context) {
    final permission = context
        .select<NotificationPermissionBloc, NotificationPermission?>(
          (bloc) => bloc.state.permission,
        );
    return Row(
      children: [
        const Icon(Icons.notifications_outlined, color: AppColors.muted),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Notifications',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        ..._buildState(context, permission),
      ],
    );
  }

  // Nothing until the phone told: neither "Activées" nor a button by
  // mistake.
  List<Widget> _buildState(
    BuildContext context,
    NotificationPermission? permission,
  ) => switch (permission) {
    null => const [],
    // The app cannot take the permission back: "Désactiver" opens the phone's
    // settings (spec permission-notifications.md, point 8).
    NotificationPermission.granted => [
      const Text('Activées', style: TextStyle(color: AppColors.muted)),
      const SizedBox(width: 8),
      OutlineButton(
        size: ButtonSize.small,
        onPressed: () => context.read<NotificationPermissionBloc>().add(
          const NotificationSettingsOpened(),
        ),
        child: const Text('Désactiver'),
      ),
    ],
    NotificationPermission.denied ||
    NotificationPermission.permanentlyDenied => [
      const Text('Désactivées', style: TextStyle(color: AppColors.muted)),
      const SizedBox(width: 8),
      OutlineButton(
        size: ButtonSize.small,
        onPressed: () => context.read<NotificationPermissionBloc>().add(
          const NotificationPermissionEnabled(),
        ),
        child: const Text('Activer'),
      ),
    ],
  };
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/presentation/bloc/notification_permission_bloc.dart';
import 'package:mobile/core/widgets/message_toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

const _title = 'Notifications désactivées';

// What the person misses: the consequence of their choice, without insisting.
String _consequence(NotificationNeed need) => switch (need) {
  NotificationNeed.rideUpdates =>
    'Vous ne serez pas prévenu quand votre taxi arrive.',
  NotificationNeed.rideRequests =>
    'Vous ne recevrez pas les courses quand l’app n’est pas à l’écran.',
  NotificationNeed.bookingReminder =>
    'Vous ne recevrez pas le rappel de cette réservation.',
};

/// The driver stays on the same screen: a message at the bottom.
void showNotificationsBlockedToast(
  BuildContext context,
  NotificationNeed need,
) {
  final bloc = context.read<NotificationPermissionBloc>();
  showMessageToast(
    context,
    title: _title,
    message: _consequence(need),
    actionLabel: 'Réglages',
    onAction: () => bloc.add(const NotificationSettingsOpened()),
  );
}

/// The passenger leaves the screen right after: a dialog, closed before the
/// next screen opens. A message at the bottom would go with the screen.
/// Docs: shadcn_flutter 0.0.51, showDialog and AlertDialog.
Future<void> showNotificationsBlockedDialog(
  BuildContext context,
  NotificationNeed need,
) {
  final bloc = context.read<NotificationPermissionBloc>();
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(_title),
      content: Text(_consequence(need)),
      actions: [
        OutlineButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            bloc.add(const NotificationSettingsOpened());
          },
          child: const Text('Réglages'),
        ),
        PrimaryButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Continuer'),
        ),
      ],
    ),
  );
}

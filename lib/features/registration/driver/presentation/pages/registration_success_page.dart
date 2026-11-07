import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/entities/notification_permission.dart';
import 'package:mobile/core/presentation/bloc/notification_permission_bloc.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/registration/driver/presentation/bloc/driver_registration_bloc.dart';
import 'package:mobile/features/registration/shared/bloc/registration_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// "Dossier en cours de vérification": the driver can allow the
/// notifications to be told of the validation, and goes to the home on their
/// own once validated. Spec taxi-vroom-api/docs/specs/validation-du-dossier.md.
class RegistrationSuccessPage extends StatefulWidget {
  const RegistrationSuccessPage({super.key});

  @override
  State<RegistrationSuccessPage> createState() =>
      _RegistrationSuccessPageState();
}

class _RegistrationSuccessPageState extends State<RegistrationSuccessPage> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    context.read<RegistrationBloc>()
      ..add(const DriverRegistrationReviewWatched())
      ..add(const DriverRegistrationReviewChecked());
    context.read<NotificationPermissionBloc>().add(
      const NotificationPermissionRead(),
    );
    _sendTokenIfAllowed();
    // Back in the app: maybe validated meanwhile, or allowed in the settings.
    _lifecycle = AppLifecycleListener(onResume: _onResumed);
  }

  // Already allowed, before this screen or by another account on this
  // phone: no change to wait for, the token is sent on arriving and on each
  // return, as the push platforms advise. Spec
  // taxi-vroom-api/docs/specs/validation-du-dossier.md.
  void _sendTokenIfAllowed() {
    final permission = context
        .read<NotificationPermissionBloc>()
        .state
        .permission;
    if (permission != NotificationPermission.granted) return;
    context.read<RegistrationBloc>().add(
      const DriverRegistrationPushTokenSent(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _onResumed() {
    context.read<RegistrationBloc>().add(
      const DriverRegistrationReviewChecked(),
    );
    context.read<NotificationPermissionBloc>().add(
      const NotificationPermissionRead(),
    );
    _sendTokenIfAllowed();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<
      NotificationPermissionBloc,
      NotificationPermissionState
    >(
      // Just allowed: the phone can be told of the validation.
      listenWhen: (previous, current) =>
          previous.permission != NotificationPermission.granted &&
          current.permission == NotificationPermission.granted,
      listener: (context, _) => context.read<RegistrationBloc>().add(
        const DriverRegistrationPushTokenSent(),
      ),
      child: Scaffold(
        backgroundColor: colorScheme.background,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  'Dossier en cours de vérification',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Votre dossier a bien été reçu. Nos équipes vont vérifier vos '
                  'documents et vous informer du résultat sous 24h.',
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                BlocBuilder<
                  NotificationPermissionBloc,
                  NotificationPermissionState
                >(
                  builder: (context, state) =>
                      _buildNotifications(state.permission),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Asked from a button, with the reason, not on arriving: after two
  // refusals the phone never shows its dialog again. After a permanent
  // refusal, the choice is respected: no lead to the settings.
  Widget _buildNotifications(NotificationPermission? permission) {
    return switch (permission) {
      NotificationPermission.granted => const Text(
        'Vous serez prévenu dès la validation.',
        style: TextStyle(color: AppColors.muted),
        textAlign: TextAlign.center,
      ),
      NotificationPermission.permanentlyDenied => const Text(
        'Notifications désactivées : vous verrez la validation en rouvrant '
        'l’app.',
        style: TextStyle(color: AppColors.muted),
        textAlign: TextAlign.center,
      ),
      NotificationPermission.denied || null => Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Soyez prévenu dès la validation',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Activez les notifications pour savoir quand vous pourrez '
              'prendre vos premières courses.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              onPressed: () => context.read<NotificationPermissionBloc>().add(
                const NotificationPermissionChecked(
                  need: NotificationNeed.registrationReview,
                ),
              ),
              alignment: Alignment.center,
              child: const Text('Activer les notifications'),
            ),
          ],
        ),
      ),
    };
  }
}

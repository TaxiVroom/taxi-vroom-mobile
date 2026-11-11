import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/registration/shared/bloc/registration_bloc.dart';
import 'package:mobile/features/registration/shared/bloc/registration_event.dart';
import 'package:mobile/features/registration/shared/bloc/registration_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        final (isEnabling, isSkipping) = switch (state) {
          RegistrationNotificationReady(:final isEnabling, :final isSkipping) =>
            (isEnabling, isSkipping),
          _ => (false, false),
        };
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _onBackPressed(context);
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            footers: [
              _buildFooterButtons(
                context,
                isEnabling: isEnabling,
                isSkipping: isSkipping,
              ),
            ],
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    _buildNotificationIcon(),
                    const SizedBox(height: 32),
                    const Text(
                      'Restez informé de vos\ntrajets et promotions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Recevez des alertes en temps réel sur l'état de "
                      'votre trajet, les promotions exclusives et les '
                      "nouveautés de l'application.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // While the registration is sent, both buttons are disabled and the tapped
  // one shows a spinner, as "Continuer" on the name page.
  Widget _buildFooterButtons(
    BuildContext context, {
    required bool isEnabling,
    required bool isSkipping,
  }) {
    final isSending = isEnabling || isSkipping;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildEnableNotificationsButton(
            context,
            isSending: isSending,
            isLoading: isEnabling,
          ),
          const SizedBox(height: 4),
          _buildSkipButton(
            context,
            isSending: isSending,
            isLoading: isSkipping,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: Color(0xFFEFF6FF),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.notifications_active_rounded,
        size: 72,
        color: Color(0xFF0066FF),
      ),
    );
  }

  Widget _buildEnableNotificationsButton(
    BuildContext context, {
    required bool isSending,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        onPressed: isSending
            ? null
            : () => _onNotificationPermissionRequested(context),
        alignment: Alignment.center,
        trailing: isLoading
            ? const AspectRatio(
                aspectRatio: 1,
                child: CircularProgressIndicator(onSurface: true),
              )
            : null,
        child: const Text('Activer les notifications'),
      ),
    );
  }

  Widget _buildSkipButton(
    BuildContext context, {
    required bool isSending,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      child: GhostButton(
        onPressed: isSending
            ? null
            : () => _onNotificationPermissionSkipped(context),
        alignment: Alignment.center,
        trailing: isLoading
            ? const AspectRatio(
                aspectRatio: 1,
                child: CircularProgressIndicator(),
              )
            : null,
        child: const Text(
          'Passer',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      ),
    );
  }

  void _onBackPressed(BuildContext context) {
    context.read<RegistrationBloc>().add(const RegistrationBackPressed());
  }

  void _onNotificationPermissionRequested(BuildContext context) {
    context.read<RegistrationBloc>().add(
      const RegistrationNotificationPermissionRequested(),
    );
  }

  void _onNotificationPermissionSkipped(BuildContext context) {
    context.read<RegistrationBloc>().add(
      const RegistrationNotificationPermissionSkipped(),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          footers: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: () => context.read<AuthBloc>().add(
                            const AuthNotificationPermissionRequested(),
                          ),
                      alignment: Alignment.center,
                      child: const Text('Activer les notifications'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: GhostButton(
                      onPressed: () => context.read<AuthBloc>().add(
                            const AuthNotificationPermissionSkipped(),
                          ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Passer',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      size: 72,
                      color: Color(0xFF0066FF),
                    ),
                  ),
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
        );
      },
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/authentication/presentation/widgets/auth_provider_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SocialLinkPage extends StatelessWidget {
  const SocialLinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isGoogleLoading = state is AuthGoogleSignInLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          headers: [
            AppBar(
              leading: [
                GhostButton(
                  density: ButtonDensity.icon,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back),
                ),
              ],
              backgroundColor: Colors.white,
            ),
          ],
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  const Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gagnez du temps en liant votre compte social.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 40),
                  AuthProviderButton(
                    label: 'Continuer avec Google',
                    icon: Image.asset(
                      'assets/icons/google_logo.png',
                      width: 20,
                      height: 20,
                    ),
                    loading: isGoogleLoading,
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthGoogleSignInRequested()),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Ou',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AuthProviderButton(
                    label: "Continuer avec l'email",
                    icon: const Icon(Icons.email_outlined, size: 20),
                    onPressed: isGoogleLoading
                        ? null
                        : () => context
                            .read<AuthBloc>()
                            .add(const AuthEmailOptionSelected()),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

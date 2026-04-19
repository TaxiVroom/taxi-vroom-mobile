import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/authentication/presentation/widgets/auth_provider_button.dart';
import 'package:mobile/features/registration/shared/bloc/registration_bloc.dart';
import 'package:mobile/features/registration/shared/bloc/registration_event.dart';
import 'package:mobile/features/registration/shared/bloc/registration_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SocialLinkPage extends StatelessWidget {
  const SocialLinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        final isGoogleLoading = state is RegistrationGoogleSignInLoading;

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            headers: const [
              AppBar(
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
                    _buildGoogleSignInButton(
                      context,
                      isGoogleLoading: isGoogleLoading,
                    ),
                    const SizedBox(height: 24),
                    _buildOrDivider(),
                    const SizedBox(height: 24),
                    _buildEmailSignInButton(
                      context,
                      isGoogleLoading: isGoogleLoading,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleSignInButton(
    BuildContext context, {
    required bool isGoogleLoading,
  }) {
    return AuthProviderButton(
      label: 'Continuer avec Google',
      icon: Image.asset(
        'assets/icons/google_logo.png',
        width: 20,
        height: 20,
      ),
      loading: isGoogleLoading,
      onPressed: () => _onGoogleSignInRequested(context),
    );
  }

  Widget _buildOrDivider() {
    return const Row(
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
    );
  }

  Widget _buildEmailSignInButton(
    BuildContext context, {
    required bool isGoogleLoading,
  }) {
    return AuthProviderButton(
      label: "Continuer avec l'email",
      icon: const Icon(Icons.email_outlined, size: 20),
      onPressed: isGoogleLoading ? null : () => _onEmailOptionSelected(context),
    );
  }

  void _onGoogleSignInRequested(BuildContext context) {
    context
        .read<RegistrationBloc>()
        .add(const RegistrationGoogleSignInRequested());
  }

  void _onEmailOptionSelected(BuildContext context) {
    context
        .read<RegistrationBloc>()
        .add(const RegistrationEmailOptionSelected());
  }
}

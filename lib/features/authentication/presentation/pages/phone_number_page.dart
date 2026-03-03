import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/authentication/domain/entities/user_role.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/authentication/presentation/widgets/auth_provider_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class PhoneNumberPage extends StatelessWidget {
  const PhoneNumberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthRoleSelectedState) return const SizedBox.shrink();
        final role = state.role;
        final isLoading = state is AuthPhoneNumberLoading;
        final isPhoneValid =
            state is AuthPhoneNumberInputReady && state.isPhoneValid;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _onBackPressed(context);
          },
          child: Scaffold(
            footers: const [
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Text(
                  'En continuant, vous acceptez nos Conditions '
                      "d'utilisation et notre Politique de "
                      'confidentialité.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
            child: Column(
              children: [
                _buildHeroSection(context),
                _buildFormSection(
                  context,
                  role: role,
                  isPhoneValid: isPhoneValid,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: const Color(0xFF0066FF),
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_taxi_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Votre trajet,\nen toute sérénité',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: GhostButton(
              density: ButtonDensity.icon,
              onPressed: () => _onBackPressed(context),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(
    BuildContext context, {
    required UserRole role,
    required bool isPhoneValid,
    required bool isLoading,
  }) {
    return Expanded(
      flex: 7,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Entrez votre numéro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              PhoneInput(
                initialCountry: Countries.findByCode('FR'),
                onChanged: (phoneInput) =>
                    _onPhoneNumberChanged(context, phoneInput.fullNumber),
                searchPlaceholder: const Text('Rechercher...'),
              ),
              const SizedBox(height: 16),
              _buildContinueButton(
                context,
                isPhoneValid: isPhoneValid,
                isLoading: isLoading,
              ),
              const SizedBox(height: 24),
              _buildOrDivider(),
              const SizedBox(height: 16),
              _buildGoogleSignInButton(context, role),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(
    BuildContext context, {
    required bool isPhoneValid,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        onPressed: (isPhoneValid && !isLoading)
            ? () => _onPhoneNumberSubmitted(context)
            : null,
        alignment: Alignment.center,
        trailing: isLoading
            ? const AspectRatio(
                aspectRatio: 1,
                child: CircularProgressIndicator(onSurface: true),
              )
            : null,
        child: const Text('Continuer'),
      ),
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
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context, UserRole role) {
    return AuthProviderButton(
      label: 'Continuer avec Google',
      icon: Image.asset(
        'assets/icons/google_logo.png',
        width: 20,
        height: 20,
      ),
      onPressed: () => _onGoogleSignInRequested(context, role),
    );
  }

  void _onBackPressed(BuildContext context) {
    context.read<AuthBloc>().add(const AuthBackPressed());
  }

  void _onPhoneNumberChanged(BuildContext context, String fullPhoneNumber) {
    context.read<AuthBloc>().add(
      AuthPhoneNumberChanged(internationalPhoneNumber: fullPhoneNumber),
    );
  }

  void _onPhoneNumberSubmitted(BuildContext context) {
    context.read<AuthBloc>().add(const AuthPhoneNumberSubmitted());
  }

  void _onGoogleSignInRequested(BuildContext context, UserRole role) {
    context.read<AuthBloc>().add(AuthGoogleSignInRequested(role: role));
  }
}

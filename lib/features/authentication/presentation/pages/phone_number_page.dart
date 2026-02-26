import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/authentication/presentation/widgets/auth_provider_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class PhoneNumberPage extends StatelessWidget {
  const PhoneNumberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthPhoneNumberLoading;
        final isPhoneValid =
            state is AuthPhoneNumberInputReady && state.isPhoneValid;

        return Scaffold(
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
              Expanded(
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
                                  color: Colors.white
                                      .withValues(alpha: 0.15),
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
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Contenu ───────────────────────────────────────────────
              Expanded(
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
                          onChanged: (p) => context.read<AuthBloc>().add(
                                AuthPhoneNumberChanged(
                                    internationalPhoneNumber: p.fullNumber),
                              ),
                          searchPlaceholder: const Text('Rechercher...'),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            onPressed: (isPhoneValid && !isLoading)
                                ? () => context
                                    .read<AuthBloc>()
                                    .add(const AuthPhoneNumberSubmitted())
                                : null,
                            alignment: Alignment.center,
                            trailing: isLoading
                                ? const AspectRatio(
                                    aspectRatio: 1,
                                    child: CircularProgressIndicator(
                                      onSurface: true,
                                    ),
                                  )
                                : null,
                            child: const Text('Continuer'),
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 16),
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
                        ),
                        const SizedBox(height: 16),

                        AuthProviderButton(
                          label: 'Continuer avec Google',
                          icon: Image.asset(
                            'assets/icons/google_logo.png',
                            width: 20,
                            height: 20,
                          ),
                          onPressed: () => context.read<AuthBloc>().add(
                                const AuthGoogleSignInRequested(),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

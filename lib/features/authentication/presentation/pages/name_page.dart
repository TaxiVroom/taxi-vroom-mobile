import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/authentication/presentation/bloc/passenger_registration/passenger_registration_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class NamePage extends StatelessWidget {
  const NamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PassengerRegistrationBloc, PassengerRegistrationState>(
      builder: (context, state) {
        final isLoading = state is RegRegistering;
        final isFormValid = state is RegNameInputReady && state.isFormValid;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              context.read<PassengerRegistrationBloc>().add(const RegBackPressed());
            }
          },
          child: Scaffold(
          backgroundColor: Colors.white,
          headers: [
            AppBar(
              leading: [
                GhostButton(
                  density: ButtonDensity.icon,
                  onPressed: () =>
                      context.read<PassengerRegistrationBloc>().add(const RegBackPressed()),
                  child: const Icon(Icons.arrow_back),
                ),
              ],
              title: const Text('Quel est votre nom ?'),
              backgroundColor: Colors.white,
            ),
          ],
          footers: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: (isFormValid && !isLoading)
                      ? () => context.read<PassengerRegistrationBloc>().add(const RegNameSubmitted())
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
              ),
            ),
          ],
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        placeholder: const Text('Prénom'),
                        autofocus: true,
                        onChanged: (v) => context
                            .read<PassengerRegistrationBloc>()
                            .add(RegNameFirstNameTyped(firstName: v)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        placeholder: const Text('Nom de famille'),
                        onChanged: (v) => context
                            .read<PassengerRegistrationBloc>()
                            .add(RegNameLastNameTyped(lastName: v)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Votre nom sera utilisé sur votre profil et vos reçus de trajet.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}

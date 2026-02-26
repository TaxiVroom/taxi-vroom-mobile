import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/authentication/presentation/bloc/passenger_registration/passenger_registration_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class EmailPage extends StatefulWidget {
  const EmailPage({super.key});

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<PassengerRegistrationBloc>().state.email,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PassengerRegistrationBloc, PassengerRegistrationState>(
      builder: (context, state) {
        final isChecking = state is RegEmailChecking;
        final isTaken = state is RegEmailTaken;
        final canSubmit = state is RegEmailInputReady &&
            state.isFormatValid &&
            !isChecking;

        return PopScope(
          canPop: false,
          // Le hardware back doit passer par le BLoC, pas directement par le Navigator.
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              context
                  .read<PassengerRegistrationBloc>()
                  .add(const RegBackPressed());
            }
          },
          child: Scaffold(
          backgroundColor: Colors.white,
          headers: [
            AppBar(
              leading: [
                GhostButton(
                  density: ButtonDensity.icon,
                  onPressed: () => context
                      .read<PassengerRegistrationBloc>()
                      .add(const RegBackPressed()),
                  child: const Icon(Icons.arrow_back),
                ),
              ],
              title: const Text('Quel est votre email ?'),
              backgroundColor: Colors.white,
            ),
          ],
          footers: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: canSubmit
                      ? () => context
                          .read<PassengerRegistrationBloc>()
                          .add(const RegEmailSubmitted())
                      : null,
                  alignment: Alignment.center,
                  trailing: isChecking
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
                TextField(
                  controller: _controller,
                  placeholder: const Text('votre@email.com'),
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  onChanged: (v) => context
                      .read<PassengerRegistrationBloc>()
                      .add(RegEmailTyped(email: v)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nous utiliserons votre adresse email pour vous envoyer '
                  'des informations importantes sur votre compte.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                if (isTaken) ...[
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.cancel_outlined,
                          size: 16, color: Color(0xFFDC2626)),
                      SizedBox(width: 6),
                      Text(
                        'Cet email est déjà utilisé.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Connectez-vous depuis la page d'accueil.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}

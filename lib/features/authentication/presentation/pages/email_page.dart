import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class EmailPage extends StatefulWidget {
  const EmailPage({super.key});

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isChecking = state is AuthEmailChecking;
        final isTaken = state is AuthEmailTaken;
        final canSubmit = state is AuthEmailInputReady &&
            state.isFormatValid &&
            !isChecking;

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
                          .read<AuthBloc>()
                          .add(const AuthEmailSubmitted())
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
                      .read<AuthBloc>()
                      .add(AuthEmailTyped(email: v)),
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
        );
      },
    );
  }
}

import 'package:shadcn_flutter/shadcn_flutter.dart';

// TODO: Poll GET /v1/registration-flows/me to detect when the admin moves the flow
// from PENDING_REVIEW to DOCUMENTS_CORRECTION or COMPLETE. On step change, emit
// the corresponding state in DriverRegistrationBloc to navigate automatically.
class RegistrationSuccessPage extends StatelessWidget {
  const RegistrationSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
                'Votre dossier a bien été reçu. Nos équipes vont vérifier vos documents et vous informer du résultat sous 24h.',
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

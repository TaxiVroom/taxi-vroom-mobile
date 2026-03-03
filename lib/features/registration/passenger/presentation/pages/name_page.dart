import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/registration/passenger/presentation/bloc/passenger_registration_bloc.dart';
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
            if (!didPop) _onBackPressed(context);
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            headers: [
              AppBar(
                leading: [
                  GhostButton(
                    density: ButtonDensity.icon,
                    onPressed: () => _onBackPressed(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                ],
                title: const Text('Quel est votre nom ?'),
                backgroundColor: Colors.white,
              ),
            ],
            footers: [
              _buildContinueButton(
                context,
                isFormValid: isFormValid,
                isLoading: isLoading,
              ),
            ],
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  _buildNameFields(context),
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

  Widget _buildContinueButton(
    BuildContext context, {
    required bool isFormValid,
    required bool isLoading,
  }) {
    return Container(
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
              ? () => _onNameSubmitted(context)
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
    );
  }

  Widget _buildNameFields(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            placeholder: const Text('Prénom'),
            autofocus: true,
            onChanged: (firstName) => _onFirstNameTyped(context, firstName),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            placeholder: const Text('Nom de famille'),
            onChanged: (lastName) => _onLastNameTyped(context, lastName),
          ),
        ),
      ],
    );
  }

  void _onBackPressed(BuildContext context) {
    context.read<PassengerRegistrationBloc>().add(const RegBackPressed());
  }

  void _onNameSubmitted(BuildContext context) {
    context.read<PassengerRegistrationBloc>().add(const RegNameSubmitted());
  }

  void _onFirstNameTyped(BuildContext context, String firstName) {
    context
        .read<PassengerRegistrationBloc>()
        .add(RegFirstNameTyped(firstName: firstName));
  }

  void _onLastNameTyped(BuildContext context, String lastName) {
    context
        .read<PassengerRegistrationBloc>()
        .add(RegLastNameTyped(lastName: lastName));
  }
}

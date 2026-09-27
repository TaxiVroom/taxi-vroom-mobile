import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/authentication/domain/entities/user_role.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide TextField;

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroSection(),
          _buildActionSection(context),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Expanded(
      child: ColoredBox(
        color: const Color(0xFF0066FF),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const Spacer(flex: 3),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
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
                  const SizedBox(height: 24),
                  const Text(
                    'TaxiApp',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre trajet, à votre rythme.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReserveRideButton(context),
            const SizedBox(height: 12),
            _buildBecomeDriverButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReserveRideButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        onPressed: () => _onPassengerRoleSelected(context),
        alignment: Alignment.center,
        child: const Text('Réserver un trajet'),
      ),
    );
  }

  Widget _buildBecomeDriverButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlineButton(
        onPressed: () => _onBecomeDriverPressed(context),
        alignment: Alignment.center,
        child: const Text('Devenir chauffeur'),
      ),
    );
  }

  void _onPassengerRoleSelected(BuildContext context) {
    context.read<AuthBloc>().add(
      const AuthRoleChosen(role: UserRole.passenger),
    );
  }

  void _onBecomeDriverPressed(BuildContext context) {
    context.read<AuthBloc>().add(const AuthRoleChosen(role: UserRole.driver));
  }
}

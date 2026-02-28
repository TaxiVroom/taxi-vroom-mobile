import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// If you are on an emulator and not using a test number (to be added in Firebase console), this will not work as the app is not authorized.
/// You must either use a physical device or a test number.
class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: _buildOtpContent,
    );
  }

  Widget _buildOtpContent(BuildContext context, AuthState state) {
    final phoneNumber = _resolvePhoneNumber(state);
    final isVerifying = state is AuthOtpVerifying;
    final canResend = state is AuthOtpCountdown && state.isResendAvailable;
    final remainingSeconds =
        state is AuthOtpCountdown ? state.remainingSeconds : 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.read<AuthBloc>().add(const AuthBackPressed());
        }
      },
      child: Scaffold(
      headers: [
        AppBar(
          leading: [
            GhostButton(
              density: ButtonDensity.icon,
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthBackPressed()),
              child: const Icon(Icons.arrow_back),
            ),
          ],
          title: const Text('Vérification'),
        ),
      ],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Entrez le code',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Un code SMS a été envoyé au $phoneNumber',
                style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 40),
              Center(
                child: InputOTP(
                  children: List.generate(
                    AppConstants.otpLength,
                    (_) => InputOTPChild.character(allowDigit: true),
                  ),
                  onChanged: (value) {
                    final digits = value.whereType<int>().toList();
                    if (digits.length == AppConstants.otpLength) {
                      context.read<AuthBloc>().add(
                            AuthOtpSubmitted(
                              otp: String.fromCharCodes(digits),
                              phoneNumber: phoneNumber,
                            ),
                          );
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: _buildResendControls(
                  context,
                  isVerifying: isVerifying,
                  canResend: canResend,
                  remainingSeconds: remainingSeconds,
                  phoneNumber: phoneNumber,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildResendControls(
    BuildContext context, {
    required bool isVerifying,
    required bool canResend,
    required int remainingSeconds,
    required String phoneNumber,
  }) {
    if (isVerifying) {
      return const CircularProgressIndicator(color: Color(0xFF0066FF));
    }

    if (canResend) {
      return GhostButton(
        onPressed: () => context.read<AuthBloc>().add(
              AuthOtpResendRequested(phoneNumber: phoneNumber),
            ),
        child: const Text(
          'Renvoyer le code',
          style: TextStyle(
            color: Color(0xFF0066FF),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (remainingSeconds == 0) {
      return const CircularProgressIndicator(color: Color(0xFF0066FF));
    }

    return Text(
      'Renvoyer le code dans ${remainingSeconds}s',
      style: const TextStyle(color: Color(0xFF6B7280)),
    );
  }

  String _resolvePhoneNumber(AuthState state) => switch (state) {
        AuthOtpCountdown() => state.phoneNumber,
        AuthOtpVerifying() => state.phoneNumber,
        _ => '',
      };
}

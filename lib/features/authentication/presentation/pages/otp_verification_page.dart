import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: _buildOtpContent,
    );
  }

  Widget _buildOtpContent(BuildContext context, AuthState state) {
    final phoneNumber = _getPhoneNumberFromState(state);
    final isVerifying = state is AuthOtpVerifying;
    final canResend = state is AuthOtpCountdown && state.isResendAvailable;
    final remainingSeconds = state is AuthOtpCountdown
        ? state.remainingSeconds
        : 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBackPressed(context);
      },
      child: Scaffold(
        headers: [
          AppBar(
            leading: [
              GhostButton(
                density: ButtonDensity.icon,
                onPressed: () => _onBackPressed(context),
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
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 40),
                _buildOtpInput(context, phoneNumber),
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

  Widget _buildOtpInput(BuildContext context, String phoneNumber) {
    return Center(
      child: InputOTP(
        children: List.generate(
          AppConstants.otpLength,
          (_) => InputOTPChild.character(allowDigit: true),
        ),
        onChanged: (otpDigits) =>
            _onOtpDigitsChanged(context, otpDigits, phoneNumber),
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
        onPressed: () => _onResendOtpRequested(context, phoneNumber),
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

  void _onBackPressed(BuildContext context) {
    context.read<AuthBloc>().add(const AuthBackPressed());
  }

  void _onOtpDigitsChanged(
    BuildContext context,
    List<Object?> otpDigits,
    String phoneNumber,
  ) {
    final digits = otpDigits.whereType<int>().toList();
    if (digits.length == AppConstants.otpLength) {
      context.read<AuthBloc>().add(
        AuthOtpSubmitted(
          otp: String.fromCharCodes(digits),
          phoneNumber: phoneNumber,
        ),
      );
    }
  }

  void _onResendOtpRequested(BuildContext context, String phoneNumber) {
    context.read<AuthBloc>().add(
      AuthOtpResendRequested(phoneNumber: phoneNumber),
    );
  }

  // phoneNumber est garanti présent sur tout AuthRoleSelectedState.
  String _getPhoneNumberFromState(AuthState state) =>
      state is AuthRoleSelectedState ? state.phoneNumber : '';
}

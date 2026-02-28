import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/authentication/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/create_passenger_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/request_notification_permission_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/update_registration_flow_usecase.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/authentication/presentation/navigator/passenger_registration_navigator.dart';
import 'package:mobile/features/authentication/presentation/pages/home_page.dart';
import 'package:mobile/features/authentication/presentation/pages/otp_verification_page.dart';
import 'package:mobile/features/authentication/presentation/pages/phone_number_page.dart';
import 'package:mobile/features/authentication/presentation/pages/welcome_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    show Basic, ButtonSize, PrimaryButton, SurfaceCard, Text, showToast;

/// Gère toute la navigation du tunnel d'authentification
/// en réagissant aux états du [AuthBloc].
///
/// Sur [AuthOtpVerified], fait un switch exhaustif sur le type de
/// [RegistrationFlowEntity] (sealed class) pour router vers le bon
/// navigator d'inscription — sans jamais toucher au flow passager
/// pour ajouter un flow driver.
class AuthNavigator extends StatelessWidget {
  const AuthNavigator({
    super.key,
    required this.updateRegistrationFlowUseCase,
    required this.createPassengerUseCase,
    required this.requestNotificationPermissionUseCase,
    required this.checkEmailAvailabilityUseCase,
  });

  // Use cases transmis au navigator d'inscription correspondant.
  // AuthBloc n'en a plus besoin — ils appartiennent au flow d'inscription.
  final UpdateRegistrationFlowUseCase updateRegistrationFlowUseCase;
  final CreatePassengerUseCase createPassengerUseCase;
  final RequestNotificationPermissionUseCase requestNotificationPermissionUseCase;
  final CheckEmailAvailabilityUseCase checkEmailAvailabilityUseCase;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, current) => current is AuthError,
      listener: (context, state) {
        if (state is AuthError) {
          showToast(
            context: context,
            builder: (ctx, overlay) => SurfaceCard(
              child: Basic(
                title: const Text('Erreur'),
                subtitle: Text(state.message),
                trailing: PrimaryButton(
                  size: ButtonSize.small,
                  onPressed: overlay.close,
                  child: const Text('OK'),
                ),
              ),
            ),
          );
        }
      },
      // BlocBuilder passe le dernier état au FlowBuilder à chaque émission.
      // FlowBuilder diffe les deux listes et joue push ou pop automatiquement.
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return FlowBuilder<AuthState>(
            state: state,
            onGeneratePages: (state, pages) =>
                _onGeneratePages(context, state, pages),
          );
        },
      ),
    );
  }

  /// Retourne la stack qui correspond exactement à [state].
  ///
  /// [pages] (liste précédente) est utilisé uniquement pour [AuthError] :
  /// une erreur est transitoire — le [BlocListener] affiche le toast
  /// sans changer la stack.
  List<Page<void>> _onGeneratePages(
    BuildContext context,
    AuthState state,
    List<Page<void>> pages,
  ) {
    const welcomePage = MaterialPage<void>(
      key: ValueKey('welcome'),
      child: WelcomePage(),
    );
    const phonePage = MaterialPage<void>(
      key: ValueKey('phone'),
      child: PhoneNumberPage(),
    );
    const otpPage = MaterialPage<void>(
      key: ValueKey('otp'),
      child: OtpVerificationPage(),
    );
    const homePage = MaterialPage<void>(
      key: ValueKey('home'),
      child: HomePage(),
    );

    // AuthError ne change pas la stack : le BlocListener se charge du toast.
    if (state is AuthError) return pages.isNotEmpty ? pages : [welcomePage];

    return switch (state) {
      AuthInitial() || AuthGoogleSignInLoading() => [welcomePage],
      AuthPhoneNumberInputReady() || AuthPhoneNumberLoading() => [
          welcomePage,
          phonePage,
        ],
      AuthOtpSent() || AuthOtpCountdown() || AuthOtpVerifying() => [
          welcomePage,
          phonePage,
          otpPage,
        ],
      AuthOtpVerified(:final registrationFlow) => [
          switch (registrationFlow) {
            // TODO: ajouter case DriverRegistrationFlowEntity() → DriverRegistrationNavigator
            PassengerRegistrationFlowEntity() => MaterialPage<void>(
                key: const ValueKey('passenger-registration'),
                child: PassengerRegistrationNavigator(
                  registrationFlow: registrationFlow,
                  updateRegistrationFlowUseCase: updateRegistrationFlowUseCase,
                  createPassengerUseCase: createPassengerUseCase,
                  requestNotificationPermissionUseCase:
                      requestNotificationPermissionUseCase,
                  checkEmailAvailabilityUseCase: checkEmailAvailabilityUseCase,
                  // onAuthenticated remonte l'événement à AuthBloc —
                  // c'est lui qui pilote la transition finale vers HomePage.
                  onAuthenticated: () => context
                      .read<AuthBloc>()
                      .add(const AuthRegistrationCompleted()),
                ),
              ),
          },
        ],
      AuthAuthenticated() => [homePage],
      _ => [welcomePage],
    };
  }
}

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
class AuthNavigator extends StatefulWidget {
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
  State<AuthNavigator> createState() => _AuthNavigatorState();
}

// TODO: Use FlowBuilder like PassengerRegistrationNavigator
class _AuthNavigatorState extends State<AuthNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // TODO: Check if we can do without this listenWhen --> with FlowBuilder like PassengerRegistrationNavigator
      listenWhen: (previous, current) {
        if (current is AuthPhoneNumberInputReady) return false;
        if (current is AuthGoogleSignInLoading) return false;
        return true;
      },
      listener: (context, state) {
        switch (state) {
          case AuthOtpSent():
            _navigator.pushNamed('/otp');
          case AuthOtpVerified(:final registrationFlow):
            // Switch exhaustif sur la sealed class — le compilateur force
            // la gestion de chaque rôle. Ajouter un driver = ajouter un case ici
            // et créer DriverRegistrationNavigator. Rien d'autre ne change.
            switch (registrationFlow) {
              case PassengerRegistrationFlowEntity():
                _navigator.pushAndRemoveUntil(
                  _registrationRoute(registrationFlow),
                  (_) => false,
                );
              // TODO: case DriverRegistrationFlowEntity(): → DriverRegistrationNavigator
            }
          case AuthError():
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
          case _:
            break;
        }
      },
      child: Navigator(
        key: _navigatorKey,
        initialRoute: '/welcome',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  /// Construit la route vers [PassengerRegistrationNavigator].
  /// Isolé dans une méthode pour garder le listener lisible.
  Route<void> _registrationRoute(PassengerRegistrationFlowEntity flow) {
    return _slideRoute(
      PassengerRegistrationNavigator(
        registrationFlow: flow,
        updateRegistrationFlowUseCase: widget.updateRegistrationFlowUseCase,
        createPassengerUseCase: widget.createPassengerUseCase,
        requestNotificationPermissionUseCase:
            widget.requestNotificationPermissionUseCase,
        checkEmailAvailabilityUseCase: widget.checkEmailAvailabilityUseCase,
        onAuthenticated: () =>
            _navigator.pushNamedAndRemoveUntil('/home', (_) => false),
      ),
    );
  }

  Route<void> _onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      '/phone' => const PhoneNumberPage(),
      '/otp' => const OtpVerificationPage(),
      '/home' => const HomePage(),
      _ => const WelcomePage(),
    };
    return _slideRoute(page);
  }

  PageRouteBuilder<void> _slideRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      ),
    );
  }
}

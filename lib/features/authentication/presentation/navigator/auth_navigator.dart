import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show Basic, ButtonSize, PrimaryButton, SurfaceCard, Text, showToast;
import 'package:mobile/features/authentication/presentation/pages/email_page.dart';
import 'package:mobile/features/authentication/presentation/pages/home_page.dart';
import 'package:mobile/features/authentication/presentation/pages/name_page.dart';
import 'package:mobile/features/authentication/presentation/pages/notifications_page.dart';
import 'package:mobile/features/authentication/presentation/pages/otp_verification_page.dart';
import 'package:mobile/features/authentication/presentation/pages/phone_number_page.dart';
import 'package:mobile/features/authentication/presentation/pages/social_link_page.dart';
import 'package:mobile/features/authentication/presentation/pages/welcome_page.dart';

/// Gère toute la navigation du tunnel d'authentification
/// en réagissant aux états du [AuthBloc].
class AuthNavigator extends StatefulWidget {
  const AuthNavigator({super.key});

  @override
  State<AuthNavigator> createState() => _AuthNavigatorState();
}

class _AuthNavigatorState extends State<AuthNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        if (current is AuthPhoneNumberInputReady) return false;
        if (current is AuthEmailInputReady) {
          return previous is! AuthEmailInputReady &&
              previous is! AuthEmailChecking &&
              previous is! AuthEmailTaken;
        }
        if (current is AuthNameInputReady) {
          return previous is! AuthNameInputReady;
        }
        return true;
      },
      listener: (context, state) {
        switch (state) {
          case AuthOtpSent():
            _navigator.pushNamed('/otp');
          case AuthNewUserDetected():
            _navigator.pushNamed('/social-link');
          case AuthEmailInputReady():
            _navigator.pushNamed('/email');
          case AuthNameInputReady():
            _navigator.pushNamed('/name');
          case AuthNotificationReady():
            _navigator.pushNamed('/notifications');
          case AuthAuthenticated():
            _navigator.pushNamedAndRemoveUntil('/home', (_) => false);
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

  Route<void> _onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      '/phone' => const PhoneNumberPage(),
      '/otp' => const OtpVerificationPage(),
      '/social-link' => const SocialLinkPage(),
      '/email' => const EmailPage(),
      '/name' => const NamePage(),
      '/notifications' => const NotificationsPage(),
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

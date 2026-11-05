import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/core/domain/usecases/ensure_notification_permission_usecase.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/complete_passenger_registration_usecase.dart';
import 'package:mobile/features/registration/passenger/presentation/bloc/passenger_registration_bloc.dart';
import 'package:mobile/features/registration/shared/bloc/registration_bloc.dart';
import 'package:mobile/features/registration/shared/bloc/registration_state.dart';
import 'package:mobile/features/registration/shared/domain/usecases/update_registration_flow_usecase.dart';
import 'package:mobile/features/registration/shared/pages/email_page.dart';
import 'package:mobile/features/registration/shared/pages/name_page.dart';
import 'package:mobile/features/registration/shared/pages/notifications_page.dart';
import 'package:mobile/features/registration/shared/pages/social_link_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    show Basic, ButtonSize, PrimaryButton, SurfaceCard, Text, showToast;

/// Reçoit le [registrationFlow] déjà fetché par [AuthBloc] —
/// pas de double fetch. Le bloc démarre directement à la bonne étape.
class PassengerRegistrationNavigator extends StatefulWidget {
  const PassengerRegistrationNavigator({
    super.key,
    required this.registrationFlow,
    required this.updateRegistrationFlowUseCase,
    required this.ensureNotificationPermissionUseCase,
    required this.checkEmailAvailabilityUseCase,
    required this.completePassengerRegistrationUseCase,
    required this.onAuthenticated,
  });

  final PassengerRegistrationFlowEntity registrationFlow;
  final UpdateRegistrationFlowUseCase updateRegistrationFlowUseCase;
  final EnsureNotificationPermissionUseCase ensureNotificationPermissionUseCase;
  final CheckEmailAvailabilityUseCase checkEmailAvailabilityUseCase;
  final CompletePassengerRegistrationUseCase
  completePassengerRegistrationUseCase;

  /// Permet au parent ([AuthNavigator]) de naviguer vers l'écran principal
  /// sans que ce widget ait besoin de connaître la navigation extérieure.
  final VoidCallback onAuthenticated;

  @override
  State<PassengerRegistrationNavigator> createState() =>
      _PassengerRegistrationNavigatorState();
}

class _PassengerRegistrationNavigatorState
    extends State<PassengerRegistrationNavigator> {
  late final PassengerRegistrationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = PassengerRegistrationBloc(
      registrationFlow: widget.registrationFlow,
      updateRegistrationFlowUseCase: widget.updateRegistrationFlowUseCase,
      ensureNotificationPermissionUseCase:
          widget.ensureNotificationPermissionUseCase,
      checkEmailAvailabilityUseCase: widget.checkEmailAvailabilityUseCase,
      completePassengerRegistrationUseCase:
          widget.completePassengerRegistrationUseCase,
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BlocProvider<RegistrationBloc> expose le bloc concret via son type abstrait —
    // les pages partagées lisent RegistrationBloc sans connaître PassengerRegistrationBloc.
    return BlocProvider<RegistrationBloc>.value(
      value: _bloc,
      child: BlocListener<RegistrationBloc, RegistrationState>(
        listener: _onRegistrationStateChanged,
        // BlocBuilder passe le dernier état au FlowBuilder à chaque émission.
        // FlowBuilder diffe les deux listes et joue push ou pop automatiquement —
        // sans aucun appel impératif.
        child: BlocBuilder<RegistrationBloc, RegistrationState>(
          builder: (context, state) {
            return FlowBuilder<RegistrationState>(
              state: state,
              onGeneratePages: _onGeneratePages,
            );
          },
        ),
      ),
    );
  }

  void _onRegistrationStateChanged(
    BuildContext context,
    RegistrationState state,
  ) {
    switch (state) {
      case RegistrationAuthenticated():
        widget.onAuthenticated();
      case RegistrationError():
        _onRegistrationError(context, state);
      case _:
        break;
    }
  }

  void _onRegistrationError(BuildContext context, RegistrationError error) {
    showToast(
      context: context,
      builder: (ctx, overlay) => SurfaceCard(
        child: Basic(
          title: const Text('Erreur'),
          subtitle: Text(error.message),
          trailing: PrimaryButton(
            size: ButtonSize.small,
            onPressed: overlay.close,
            child: const Text('OK'),
          ),
        ),
      ),
    );
  }

  /// Les [ValueKey] stables permettent au Navigator de choisir automatiquement
  /// l'animation push (page ajoutée en fin) ou pop (page retirée en fin).
  ///
  /// [pages] est utilisé uniquement pour [RegistrationError] : erreur transitoire —
  /// le [BlocListener] affiche le toast sans changer la stack.
  List<Page<void>> _onGeneratePages(
    RegistrationState state,
    List<Page<void>> pages,
  ) {
    const socialPage = MaterialPage<void>(
      key: ValueKey('passenger-social-link'),
      child: SocialLinkPage(),
    );
    const emailPage = MaterialPage<void>(
      key: ValueKey('passenger-email'),
      child: EmailPage(),
    );
    const namePage = MaterialPage<void>(
      key: ValueKey('passenger-name'),
      child: NamePage(),
    );
    const notificationsPage = MaterialPage<void>(
      key: ValueKey('passenger-notifications'),
      child: NotificationsPage(),
    );

    // RegistrationError ne change pas la stack : le BlocListener se charge du toast.
    if (state is RegistrationError) {
      return pages.isNotEmpty ? pages : [socialPage];
    }

    return switch (state) {
      RegistrationSocialLinkReady() ||
      RegistrationGoogleSignInLoading() => [socialPage],
      RegistrationEmailInputReady() ||
      RegistrationEmailChecking() ||
      RegistrationEmailTaken() => [socialPage, emailPage],
      RegistrationNameInputReady() ||
      RegistrationRegistering() => [socialPage, emailPage, namePage],
      RegistrationNotificationReady() || RegistrationAuthenticated() => [
        socialPage,
        emailPage,
        namePage,
        notificationsPage,
      ],
      _ => pages.isNotEmpty ? pages : [socialPage],
    };
  }
}

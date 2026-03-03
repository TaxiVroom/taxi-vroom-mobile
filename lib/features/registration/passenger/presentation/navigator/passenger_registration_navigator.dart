import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/create_passenger_usecase.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/request_notification_permission_usecase.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/update_registration_flow_usecase.dart';
import 'package:mobile/features/registration/passenger/presentation/bloc/passenger_registration_bloc.dart';
import 'package:mobile/features/registration/passenger/presentation/pages/email_page.dart';
import 'package:mobile/features/registration/passenger/presentation/pages/name_page.dart';
import 'package:mobile/features/registration/passenger/presentation/pages/notifications_page.dart';
import 'package:mobile/features/registration/passenger/presentation/pages/social_link_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    show Basic, ButtonSize, PrimaryButton, SurfaceCard, Text, showToast;

/// Reçoit le [registrationFlow] déjà fetché par [AuthBloc] —
/// pas de double fetch. Le bloc démarre directement à la bonne étape.
class PassengerRegistrationNavigator extends StatefulWidget {
  const PassengerRegistrationNavigator({
    super.key,
    required this.registrationFlow,
    required this.updateRegistrationFlowUseCase,
    required this.createPassengerUseCase,
    required this.requestNotificationPermissionUseCase,
    required this.checkEmailAvailabilityUseCase,
    required this.onAuthenticated,
  });

  final PassengerRegistrationFlowEntity registrationFlow;
  final UpdateRegistrationFlowUseCase updateRegistrationFlowUseCase;
  final CreatePassengerUseCase createPassengerUseCase;
  final RequestNotificationPermissionUseCase requestNotificationPermissionUseCase;
  final CheckEmailAvailabilityUseCase checkEmailAvailabilityUseCase;

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
      createPassengerUseCase: widget.createPassengerUseCase,
      requestNotificationPermissionUseCase:
          widget.requestNotificationPermissionUseCase,
      checkEmailAvailabilityUseCase: widget.checkEmailAvailabilityUseCase,
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PassengerRegistrationBloc>.value(
      value: _bloc,
      child: BlocListener<PassengerRegistrationBloc, PassengerRegistrationState>(
        listener: _onRegistrationStateChanged,
        // BlocBuilder passe le dernier état au FlowBuilder à chaque émission.
        // FlowBuilder diffe les deux listes et joue push ou pop automatiquement —
        // sans aucun appel impératif.
        child: BlocBuilder<PassengerRegistrationBloc, PassengerRegistrationState>(
          builder: (context, state) {
            return FlowBuilder<PassengerRegistrationState>(
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
    PassengerRegistrationState state,
  ) {
    switch (state) {
      case RegAuthenticated():
        widget.onAuthenticated();
      case RegError():
        _onRegistrationError(context, state);
      case _:
        break;
    }
  }

  void _onRegistrationError(BuildContext context, RegError error) {
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
  /// [pages] est utilisé uniquement pour [RegError] : erreur transitoire —
  /// le [BlocListener] affiche le toast sans changer la stack.
  List<Page<void>> _onGeneratePages(
    PassengerRegistrationState state,
    List<Page<void>> pages,
  ) {
    const socialPage = MaterialPage<void>(
      key: ValueKey(PassengerRegistrationStep.socialLink),
      child: SocialLinkPage(),
    );
    const emailPage = MaterialPage<void>(
      key: ValueKey(PassengerRegistrationStep.email),
      child: EmailPage(),
    );
    const namePage = MaterialPage<void>(
      key: ValueKey(PassengerRegistrationStep.name),
      child: NamePage(),
    );
    const notificationsPage = MaterialPage<void>(
      key: ValueKey(PassengerRegistrationStep.complete),
      child: NotificationsPage(),
    );

    // RegError ne change pas la stack : le BlocListener se charge du toast.
    if (state is RegError) return pages.isNotEmpty ? pages : [socialPage];

    return switch (state.currentStep) {
      PassengerRegistrationStep.socialLink => [socialPage],
      PassengerRegistrationStep.email     => [socialPage, emailPage],
      PassengerRegistrationStep.name      => [socialPage, emailPage, namePage],
      PassengerRegistrationStep.complete  => [socialPage, emailPage, namePage, notificationsPage],
    };
  }
}

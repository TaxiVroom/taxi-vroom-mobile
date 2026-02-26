import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/authentication/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/create_passenger_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/request_notification_permission_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/update_registration_flow_usecase.dart';
import 'package:mobile/features/authentication/presentation/bloc/passenger_registration/passenger_registration_bloc.dart';
import 'package:mobile/features/authentication/presentation/pages/email_page.dart';
import 'package:mobile/features/authentication/presentation/pages/name_page.dart';
import 'package:mobile/features/authentication/presentation/pages/notifications_page.dart';
import 'package:mobile/features/authentication/presentation/pages/social_link_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    show Basic, ButtonSize, PrimaryButton, SurfaceCard, Text, showToast;

/// Gère toute la navigation du tunnel d'inscription passager
/// en réagissant aux états du [PassengerRegistrationBloc].
///
/// Reçoit le [registrationFlow] déjà fetché par [AuthBloc] —
/// pas besoin de le re-fetcher. Le bloc démarre immédiatement
/// à la bonne étape via son bootstrap interne ([RegStarted]).
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

  /// Appelé quand [RegAuthenticated] est émis.
  /// Permet au parent (AuthNavigator) de naviguer vers l'écran principal
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
        listener: (context, state) {
          switch (state) {
            case RegAuthenticated():
              widget.onAuthenticated();
            case RegError():
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

  /// Retourne la stack qui correspond exactement à [state].
  ///
  /// Les [ValueKey] stables permettent au Navigator de differ les deux listes
  /// et de choisir automatiquement l'animation push (page ajoutée en fin)
  /// ou pop (page retirée en fin).
  ///
  /// [pages] (liste précédente) est utilisé uniquement pour [RegError] :
  /// une erreur est transitoire et ne doit pas faire bouger la stack —
  /// le [BlocListener] affiche le toast.
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

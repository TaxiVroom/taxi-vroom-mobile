import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/core/domain/usecases/ensure_notification_permission_usecase.dart';
import 'package:mobile/core/domain/usecases/watch_pushed_rides_usecase.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/driver/domain/usecases/check_registration_validated_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_document_signed_url_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_document_types_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/get_uploaded_documents_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/search_communes_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/send_registration_push_token_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/submit_registration_vehicle_usecase.dart';
import 'package:mobile/features/registration/driver/domain/usecases/upload_registration_document_usecase.dart';
import 'package:mobile/features/registration/driver/presentation/bloc/driver_registration_bloc.dart';
import 'package:mobile/features/registration/driver/presentation/pages/driver_documents_page.dart';
import 'package:mobile/features/registration/driver/presentation/pages/driver_vehicle_page.dart';
import 'package:mobile/features/registration/driver/presentation/pages/registration_success_page.dart';
import 'package:mobile/features/registration/shared/bloc/registration_bloc.dart';
import 'package:mobile/features/registration/shared/bloc/registration_state.dart';
import 'package:mobile/features/registration/shared/domain/usecases/update_registration_flow_usecase.dart';
import 'package:mobile/features/registration/shared/pages/email_page.dart';
import 'package:mobile/features/registration/shared/pages/name_page.dart';
import 'package:mobile/features/registration/shared/pages/social_link_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    show Basic, ButtonSize, PrimaryButton, SurfaceCard, Text, showToast;

/// Reçoit le [registrationFlow] déjà fetché par [AuthBloc] —
/// pas de double fetch. Le bloc démarre directement à la bonne étape.
class DriverRegistrationNavigator extends StatefulWidget {
  const DriverRegistrationNavigator({
    super.key,
    required this.registrationFlow,
    required this.updateRegistrationFlowUseCase,
    required this.ensureNotificationPermissionUseCase,
    required this.checkEmailAvailabilityUseCase,
    required this.getDocumentTypesUseCase,
    required this.uploadRegistrationDocumentUseCase,
    required this.getUploadedDocumentsUseCase,
    required this.getDocumentSignedUrlUseCase,
    required this.submitRegistrationVehicleUseCase,
    required this.searchCommunesUseCase,
    required this.checkRegistrationValidatedUseCase,
    required this.sendRegistrationPushTokenUseCase,
    required this.watchPushedRidesUseCase,
    required this.onAuthenticated,
  });

  final DriverRegistrationFlowEntity registrationFlow;
  final UpdateRegistrationFlowUseCase updateRegistrationFlowUseCase;
  final EnsureNotificationPermissionUseCase ensureNotificationPermissionUseCase;
  final CheckEmailAvailabilityUseCase checkEmailAvailabilityUseCase;
  final GetDocumentTypesUseCase getDocumentTypesUseCase;
  final UploadRegistrationDocumentUseCase uploadRegistrationDocumentUseCase;
  final GetUploadedDocumentsUseCase getUploadedDocumentsUseCase;
  final GetDocumentSignedUrlUseCase getDocumentSignedUrlUseCase;
  final SubmitRegistrationVehicleUseCase submitRegistrationVehicleUseCase;
  final SearchCommunesUseCase searchCommunesUseCase;
  final CheckRegistrationValidatedUseCase checkRegistrationValidatedUseCase;
  final SendRegistrationPushTokenUseCase sendRegistrationPushTokenUseCase;
  final WatchPushedRidesUseCase watchPushedRidesUseCase;

  /// Permet au parent ([AuthNavigator]) de naviguer vers l'écran principal
  /// sans que ce widget ait besoin de connaître la navigation extérieure.
  final VoidCallback onAuthenticated;

  @override
  State<DriverRegistrationNavigator> createState() =>
      _DriverRegistrationNavigatorState();
}

class _DriverRegistrationNavigatorState
    extends State<DriverRegistrationNavigator> {
  late final DriverRegistrationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = DriverRegistrationBloc(
      registrationFlow: widget.registrationFlow,
      updateRegistrationFlowUseCase: widget.updateRegistrationFlowUseCase,
      ensureNotificationPermissionUseCase:
          widget.ensureNotificationPermissionUseCase,
      checkEmailAvailabilityUseCase: widget.checkEmailAvailabilityUseCase,
      getDocumentTypesUseCase: widget.getDocumentTypesUseCase,
      uploadRegistrationDocumentUseCase:
          widget.uploadRegistrationDocumentUseCase,
      getUploadedDocumentsUseCase: widget.getUploadedDocumentsUseCase,
      getDocumentSignedUrlUseCase: widget.getDocumentSignedUrlUseCase,
      submitRegistrationVehicleUseCase: widget.submitRegistrationVehicleUseCase,
      checkRegistrationValidatedUseCase:
          widget.checkRegistrationValidatedUseCase,
      sendRegistrationPushTokenUseCase: widget.sendRegistrationPushTokenUseCase,
      watchPushedRidesUseCase: widget.watchPushedRidesUseCase,
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
    // les pages partagées lisent RegistrationBloc sans connaître DriverRegistrationBloc.
    // BlocProvider<DriverRegistrationBloc> expose le même bloc pour les pages driver
    // qui ont besoin de dispatcher des événements spécifiques au flow chauffeur.
    return BlocProvider<RegistrationBloc>.value(
      value: _bloc,
      child: BlocProvider<DriverRegistrationBloc>.value(
        value: _bloc,
        child: BlocListener<RegistrationBloc, RegistrationState>(
          listener: _onRegistrationStateChanged,
          child: BlocBuilder<RegistrationBloc, RegistrationState>(
            builder: (context, state) {
              return FlowBuilder<RegistrationState>(
                state: state,
                onGeneratePages: _onGeneratePages,
              );
            },
          ),
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
      key: ValueKey('driver-social-link'),
      child: SocialLinkPage(),
    );
    const emailPage = MaterialPage<void>(
      key: ValueKey('driver-email'),
      child: EmailPage(),
    );
    const namePage = MaterialPage<void>(
      key: ValueKey('driver-name'),
      child: NamePage(),
    );
    final vehiclePage = MaterialPage<void>(
      key: const ValueKey('driver-vehicle'),
      child: DriverVehiclePage(
        searchCommunesUseCase: widget.searchCommunesUseCase,
      ),
    );
    const documentsPage = MaterialPage<void>(
      key: ValueKey('driver-documents'),
      child: DriverDocumentsPage(),
    );
    const successPage = MaterialPage<void>(
      key: ValueKey('driver-success'),
      child: RegistrationSuccessPage(),
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
      DriverRegVehicleReady() => [socialPage, emailPage, namePage, vehiclePage],
      DriverRegDocumentsReady() => [
        socialPage,
        emailPage,
        namePage,
        vehiclePage,
        documentsPage,
      ],
      DriverRegSuccessReady() || RegistrationAuthenticated() => [
        socialPage,
        emailPage,
        namePage,
        vehiclePage,
        documentsPage,
        successPage,
      ],
      _ => pages.isNotEmpty ? pages : [socialPage],
    };
  }
}

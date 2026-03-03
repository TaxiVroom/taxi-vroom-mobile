import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/passenger/domain/entities/registration_flow_update.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/create_passenger_usecase.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/request_notification_permission_usecase.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/update_registration_flow_usecase.dart';
import 'package:mobile/features/registration/passenger/domain/utils/email_validator.dart';

part 'passenger_registration_event.dart';
part 'passenger_registration_state.dart';

class PassengerRegistrationBloc
    extends Bloc<PassengerRegistrationEvent, PassengerRegistrationState> {
  PassengerRegistrationBloc({
    required PassengerRegistrationFlowEntity registrationFlow,
    required UpdateRegistrationFlowUseCase updateRegistrationFlowUseCase,
    required CreatePassengerUseCase createPassengerUseCase,
    required RequestNotificationPermissionUseCase requestNotificationPermissionUseCase,
    required CheckEmailAvailabilityUseCase checkEmailAvailabilityUseCase,
  })  : _registrationFlow = registrationFlow,
        _updateRegistrationFlowUseCase = updateRegistrationFlowUseCase,
        _createPassengerUseCase = createPassengerUseCase,
        _requestNotificationPermissionUseCase = requestNotificationPermissionUseCase,
        _checkEmailAvailabilityUseCase = checkEmailAvailabilityUseCase,
        // L'état initial encode déjà l'étape de reprise et les données connues —
        // pas besoin d'un bootstrap event pour déterminer la page de départ.
        super(_initialState(registrationFlow)) {
    on<RegGoogleSignInRequested>(_onGoogleSignInRequested);
    on<RegEmailOptionSelected>(_onEmailOptionSelected);
    on<RegEmailTyped>(_onEmailTyped);
    on<RegEmailSubmitted>(_onEmailSubmitted);
    on<RegFirstNameTyped>(_onFirstNameTyped);
    on<RegLastNameTyped>(_onLastNameTyped);
    on<RegNameSubmitted>(_onNameSubmitted);
    on<RegBackPressed>(_onBackPressed);
    on<RegNotificationPermissionRequested>(_onNotificationPermissionRequested);
    on<RegNotificationPermissionSkipped>(_onNotificationPermissionSkipped);
  }

  final PassengerRegistrationFlowEntity _registrationFlow;
  final UpdateRegistrationFlowUseCase _updateRegistrationFlowUseCase;
  final CreatePassengerUseCase _createPassengerUseCase;
  final RequestNotificationPermissionUseCase _requestNotificationPermissionUseCase;
  final CheckEmailAvailabilityUseCase _checkEmailAvailabilityUseCase;

  String get _userId => _registrationFlow.userId;

  // FIXME: Business logic present in the Presentation layer.
  // This orchestration (step routing based on registrationFlow) should be
  // moved to a dedicated UseCase in the Domain layer.
  // To be refactored to comply with Clean Architecture (10 years maintenance).
  static PassengerRegistrationState _initialState(
    PassengerRegistrationFlowEntity flow,
  ) {
    log(
        '[PassengerRegistrationBloc] RegistrationFlow reçu :\n${const JsonEncoder.withIndent('  ').convert({
      'userId': flow.userId,
      'currentStep': flow.currentStep.name,
      'email': flow.email,
      'firstName': flow.firstName,
      'lastName': flow.lastName,
    })}');

    return switch (flow.currentStep) {
      PassengerRegistrationStep.socialLink => RegSocialLinkReady(
          currentStep: flow.currentStep,
        ),
      PassengerRegistrationStep.email => RegEmailInputReady(
          currentStep: flow.currentStep,
          email: flow.email ?? '',
        ),
      PassengerRegistrationStep.name => RegNameInputReady(
          currentStep: flow.currentStep,
          email: flow.email ?? '',
          firstName: flow.firstName ?? '',
          lastName: flow.lastName ?? '',
        ),
      PassengerRegistrationStep.complete => RegNotificationReady(
          currentStep: flow.currentStep,
          email: flow.email ?? '',
          firstName: flow.firstName ?? '',
          lastName: flow.lastName ?? '',
        ),
    };
  }

  Future<void> _onGoogleSignInRequested(
    RegGoogleSignInRequested event,
    Emitter<PassengerRegistrationState> emit,
  ) async {
    emit(RegGoogleSignInLoading(
      currentStep: state.currentStep,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
    ));
    try {
      // TODO: Remplacer par vrai Google Sign-In + currentStep = updatedFlow.currentStep
      await Future<void>.delayed(const Duration(seconds: 1));
      emit(RegNotificationReady(
        currentStep: PassengerRegistrationStep.complete,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ));
    } catch (e) {
      emit(RegError(
        message: e.toString(),
        currentStep: state.currentStep,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ));
      emit(RegSocialLinkReady(
        currentStep: state.currentStep,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ));
    }
  }

  void _onEmailOptionSelected(
    RegEmailOptionSelected event,
    Emitter<PassengerRegistrationState> emit,
  ) {
    // Mise à jour locale : le backend sera synchronisé lors du submit de l'email.
    emit(RegEmailInputReady(
      currentStep: PassengerRegistrationStep.email,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
    ));
  }

  void _onEmailTyped(
    RegEmailTyped event,
    Emitter<PassengerRegistrationState> emit,
  ) {
    // Guard : applicable aussi depuis RegEmailTaken/RegEmailChecking —
    // taper efface l'état d'erreur et repasse en saisie.
    if (state.currentStep != PassengerRegistrationStep.email) return;
    final email = event.email.trim();
    emit(RegEmailInputReady(
      currentStep: state.currentStep,
      email: email,
      firstName: state.firstName,
      lastName: state.lastName,
      isFormatValid: EmailValidator.isValid(email),
    ));
  }

  Future<void> _onEmailSubmitted(
    RegEmailSubmitted event,
    Emitter<PassengerRegistrationState> emit,
  ) async {
    emit(RegEmailChecking(
      currentStep: state.currentStep,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
    ));
    try {
      final isAvailable = await _checkEmailAvailabilityUseCase(email: state.email);
      if (!isAvailable) {
        log(
            '[PassengerRegistrationBloc] Email non disponible :\n${const JsonEncoder.withIndent('  ').convert({
          'email': state.email,
          'available': false,
        })}');
        emit(RegEmailTaken(
          currentStep: state.currentStep,
          email: state.email,
          firstName: state.firstName,
          lastName: state.lastName,
        ));
        return;
      }

      final patch = {'email': state.email};
      log(
          '[PassengerRegistrationBloc] PATCH registrationFlow :\n${const JsonEncoder.withIndent('  ').convert({
        'userId': _userId,
        'body': patch,
      })}');
      await _updateRegistrationFlowUseCase(
        userId: _userId,
        // fromStep = the step the user is completing → backend sets currentStep to
        // NEXT_STEP[fromStep], so re-submitting the same step is always idempotent.
        update: EmailUpdate(fromStep: state.currentStep, email: state.email),
      );

      // TODO: Remplacer state.currentStep.next! par updatedFlow.currentStep
      //  quand le backend renvoie le flow mis à jour après chaque PATCH.
      log('[PassengerRegistrationBloc] → NamePage  (email enregistré : ${state.email})');
      emit(RegNameInputReady(
        currentStep: state.currentStep.next!,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ));
    } catch (e) {
      emit(RegError(
        message: e.toString(),
        currentStep: state.currentStep,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ));
      emit(RegEmailInputReady(
        currentStep: state.currentStep,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
        isFormatValid: EmailValidator.isValid(state.email),
      ));
    }
  }

  void _onFirstNameTyped(
    RegFirstNameTyped event,
    Emitter<PassengerRegistrationState> emit,
  ) {
    if (state is! RegNameInputReady) return;
    final firstName = event.firstName.trim();
    final nameInputState = state as RegNameInputReady;
    emit(nameInputState.copyWith(
      firstName: firstName,
      isFormValid: firstName.isNotEmpty && nameInputState.lastName.isNotEmpty,
    ));
  }

  void _onLastNameTyped(
    RegLastNameTyped event,
    Emitter<PassengerRegistrationState> emit,
  ) {
    if (state is! RegNameInputReady) return;
    final lastName = event.lastName.trim();
    final nameInputState = state as RegNameInputReady;
    emit(nameInputState.copyWith(
      lastName: lastName,
      isFormValid: nameInputState.firstName.isNotEmpty && lastName.isNotEmpty,
    ));
  }

  Future<void> _onNameSubmitted(
    RegNameSubmitted event,
    Emitter<PassengerRegistrationState> emit,
  ) async {
    emit(RegRegistering(
      currentStep: state.currentStep,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
    ));
    try {
      log(
          '[PassengerRegistrationBloc] PATCH name :\n${const JsonEncoder.withIndent('  ').convert({
        'userId': _userId,
        'firstName': state.firstName,
        'lastName': state.lastName,
      })}');
      await _updateRegistrationFlowUseCase(
        userId: _userId,
        // fromStep = the step the user is completing → backend sets currentStep to
        // NEXT_STEP[fromStep], so re-submitting the same step is always idempotent.
        update: NameUpdate(
          fromStep: state.currentStep,
          firstName: state.firstName,
          lastName: state.lastName,
        ),
      );

      log(
          '[PassengerRegistrationBloc] POST /passengers :\n${const JsonEncoder.withIndent('  ').convert({
        'userId': _userId,
        'email': state.email,
        'firstName': state.firstName,
        'lastName': state.lastName,
      })}');
      await _createPassengerUseCase(
        userId: _userId,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      );

      // TODO: Remplacer state.currentStep.next! par updatedFlow.currentStep
      //  quand le backend renvoie le flow mis à jour après chaque PATCH.
      log('[PassengerRegistrationBloc] → NotificationPage  (passenger créé avec succès)');
      emit(RegNotificationReady(
        currentStep: state.currentStep.next!, // FIXME: Avoid the operator '!'
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ));
    } catch (e) {
      emit(RegError(
        message: e.toString(),
        currentStep: state.currentStep,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ));
      emit(RegNameInputReady(
        currentStep: state.currentStep,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
        isFormValid: true,
      ));
    }
  }

  void _onBackPressed(
    RegBackPressed event,
    Emitter<PassengerRegistrationState> emit,
  ) {
    final previousStep = state.currentStep.previous;
    log(
        '[PassengerRegistrationBloc] RegBackPressed — currentStep: "${state.currentStep.name}", previousStep: "${previousStep?.name ?? 'null (déjà au début, on ignore)'}"');
    if (previousStep == null) return;

    switch (previousStep) {
      case PassengerRegistrationStep.socialLink:
        log('[PassengerRegistrationBloc] → emit RegSocialLinkReady');
        emit(RegSocialLinkReady(
          currentStep: previousStep,
          email: state.email,
          firstName: state.firstName,
          lastName: state.lastName,
        ));
      case PassengerRegistrationStep.email:
        log('[PassengerRegistrationBloc] → emit RegEmailInputReady(email: "${state.email}")');
        emit(RegEmailInputReady(
          currentStep: previousStep,
          email: state.email,
          firstName: state.firstName,
          lastName: state.lastName,
          isFormatValid: EmailValidator.isValid(state.email),
        ));
      case PassengerRegistrationStep.name:
        log('[PassengerRegistrationBloc] → emit RegNameInputReady');
        emit(RegNameInputReady(
          currentStep: previousStep,
          email: state.email,
          firstName: state.firstName,
          lastName: state.lastName,
        ));
      case PassengerRegistrationStep.complete:
        break;
    }
  }

  Future<void> _onNotificationPermissionRequested(
    RegNotificationPermissionRequested event,
    Emitter<PassengerRegistrationState> emit,
  ) async {
    await _requestNotificationPermissionUseCase();
    emit(RegAuthenticated(
      currentStep: state.currentStep,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
    ));
  }

  void _onNotificationPermissionSkipped(
    RegNotificationPermissionSkipped event,
    Emitter<PassengerRegistrationState> emit,
  ) {
    emit(RegAuthenticated(
      currentStep: state.currentStep,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
    ));
  }
}

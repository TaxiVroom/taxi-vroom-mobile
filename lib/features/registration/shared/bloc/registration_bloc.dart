import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:mobile/core/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/core/utils/email_validator.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/shared/bloc/registration_event.dart';
import 'package:mobile/features/registration/shared/bloc/registration_state.dart';
import 'package:mobile/features/registration/shared/domain/entities/registration_flow_update.dart';
import 'package:mobile/features/registration/shared/domain/usecases/update_registration_flow_usecase.dart';

/// BLoC de base commun aux flows passager et chauffeur.
/// Gère tous les événements partagés (email, nom, notifications).
/// Chaque sous-classe injecte ses propres use cases et implémente les méthodes abstraites.
abstract class RegistrationBloc
    extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc({
    required String userId,
    required RegistrationStep emailStep,
    required RegistrationStep nameStep,
    required RegistrationStep completeStep,
    required UpdateRegistrationFlowUseCase updateRegistrationFlowUseCase,
    required CheckEmailAvailabilityUseCase checkEmailAvailabilityUseCase,
    required RegistrationState initialState,
  })  : _userId = userId,
        _emailStep = emailStep,
        _nameStep = nameStep,
        _completeStep = completeStep,
        _updateRegistrationFlowUseCase = updateRegistrationFlowUseCase,
        _checkEmailAvailabilityUseCase = checkEmailAvailabilityUseCase,
        super(initialState) {
    on<RegistrationGoogleSignInRequested>(_onGoogleSignInRequested);
    on<RegistrationEmailOptionSelected>(_onEmailOptionSelected);
    on<RegistrationEmailTyped>(_onEmailTyped);
    on<RegistrationEmailSubmitted>(_onEmailSubmitted);
    on<RegistrationFirstNameTyped>(_onFirstNameTyped);
    on<RegistrationLastNameTyped>(_onLastNameTyped);
    on<RegistrationNameSubmitted>(_onNameSubmitted);
    on<RegistrationBackPressed>(_onBackPressed);
    on<RegistrationNotificationPermissionRequested>(
        _onNotificationPermissionRequested);
    on<RegistrationNotificationPermissionSkipped>(
        _onNotificationPermissionSkipped);
  }

  final String _userId;
  final RegistrationStep _emailStep;
  final RegistrationStep _nameStep;
  final RegistrationStep _completeStep;
  final UpdateRegistrationFlowUseCase _updateRegistrationFlowUseCase;
  final CheckEmailAvailabilityUseCase _checkEmailAvailabilityUseCase;

  // Abstraites — comportement propre à chaque rôle, le compilateur force l'implémentation.

  // Maps a domain step to the corresponding presentation state for this role.
  // Each role defines its own complete step-to-state mapping.
  RegistrationState stateForStep(RegistrationStep step);

  // Each role has its own notification permission system.
  Future<void> notifyPermissionGranted();

  // Each role finalizes its registration its own way when leaving the notifications screen.
  Future<Result<void>> completeRegistration();

  // Concrete — même logique pour tous les rôles : PATCH /v1/registration-flows/me.
  Future<void> persistEmailUpdate(String email) =>
      _updateRegistrationFlowUseCase(
        userId: _userId,
        update: EmailUpdate(fromStep: _emailStep, email: email),
      );

  Future<void> persistNameUpdate(String firstName, String lastName) =>
      _updateRegistrationFlowUseCase(
        userId: _userId,
        update: NameUpdate(
          fromStep: _nameStep,
          firstName: firstName,
          lastName: lastName,
        ),
      );

  Future<void> notifyRegistrationReadyForReview(RegistrationStep fromStep) =>
      _updateRegistrationFlowUseCase(
        userId: _userId,
        update: DocumentsReadyForReviewUpdate(fromStep: fromStep),
      );

  Future<void> _onGoogleSignInRequested(
    RegistrationGoogleSignInRequested event,
    Emitter<RegistrationState> emit,
  ) async {
    // _emailStep.previous est l'étape socialLink — toujours non-null pour les deux rôles.
    final socialLinkStep = _emailStep.previous!;
    emit(RegistrationGoogleSignInLoading(
      currentStep: socialLinkStep,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
    ));
    try {
      // TODO: Remplacer par vrai Google Sign-In
      await Future<void>.delayed(const Duration(seconds: 1));
      // Google sign-in fournit email et prénom/nom — on saute directement à l'étape après nom.
      emit(stateForStep(_nameStep.next!));
    } catch (e) {
      emit(RegistrationError(
        message: e.toString(),
        currentStep: state.currentStep,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ));
      emit(RegistrationSocialLinkReady(
        currentStep: socialLinkStep,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ));
    }
  }

  void _onEmailOptionSelected(
    RegistrationEmailOptionSelected event,
    Emitter<RegistrationState> emit,
  ) {
    // Mise à jour locale : le backend sera synchronisé lors du submit de l'email.
    emit(RegistrationEmailInputReady(
      currentStep: _emailStep,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
    ));
  }

  void _onEmailTyped(
    RegistrationEmailTyped event,
    Emitter<RegistrationState> emit,
  ) {
    // Guard : applicable aussi depuis RegistrationEmailTaken/RegistrationEmailChecking —
    // taper efface l'état d'erreur et repasse en saisie.
    if (state is! RegistrationEmailInputReady &&
        state is! RegistrationEmailChecking &&
        state is! RegistrationEmailTaken) return;
    final email = event.email.trim();
    emit(RegistrationEmailInputReady(
      currentStep: _emailStep,
      email: email,
      firstName: state.firstName,
      lastName: state.lastName,
      isFormatValid: EmailValidator.isValid(email),
    ));
  }

  Future<void> _onEmailSubmitted(
    RegistrationEmailSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationEmailChecking(
      currentStep: _emailStep,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
    ));
    try {
      final isAvailable =
          await _checkEmailAvailabilityUseCase(email: state.email);
      if (!isAvailable) {
        log(
            '[RegistrationBloc] Email non disponible :\n${const JsonEncoder.withIndent('  ').convert({
          'email': state.email,
          'available': false,
        })}');
        emit(RegistrationEmailTaken(
          currentStep: _emailStep,
          email: state.email,
          firstName: state.firstName,
          lastName: state.lastName,
        ));
        return;
      }

      log(
          '[RegistrationBloc] PATCH email :\n${const JsonEncoder.withIndent('  ').convert({
        'email': state.email,
      })}');
      await persistEmailUpdate(state.email);

      // TODO: Remplacer par updatedFlow.currentStep quand le backend renvoie le flow mis à jour.
      log('[RegistrationBloc] → NamePage  (email enregistré : ${state.email})');
      emit(stateForStep(_emailStep.next!));
    } catch (e) {
      emit(RegistrationError(
        message: e.toString(),
        currentStep: state.currentStep,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ));
      emit(RegistrationEmailInputReady(
        currentStep: _emailStep,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
        isFormatValid: EmailValidator.isValid(state.email),
      ));
    }
  }

  void _onFirstNameTyped(
    RegistrationFirstNameTyped event,
    Emitter<RegistrationState> emit,
  ) {
    if (state is! RegistrationNameInputReady) return;
    final firstName = event.firstName.trim();
    final nameState = state as RegistrationNameInputReady;
    emit(nameState.copyWith(
      firstName: firstName,
      isFormValid: firstName.isNotEmpty && nameState.lastName.isNotEmpty,
    ));
  }

  void _onLastNameTyped(
    RegistrationLastNameTyped event,
    Emitter<RegistrationState> emit,
  ) {
    if (state is! RegistrationNameInputReady) return;
    final lastName = event.lastName.trim();
    final nameState = state as RegistrationNameInputReady;
    emit(nameState.copyWith(
      lastName: lastName,
      isFormValid: nameState.firstName.isNotEmpty && lastName.isNotEmpty,
    ));
  }

  Future<void> _onNameSubmitted(
    RegistrationNameSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(RegistrationRegistering(
      currentStep: _nameStep,
      email: state.email,
      firstName: state.firstName,
      lastName: state.lastName,
    ));
    try {
      log(
          '[RegistrationBloc] PATCH nom :\n${const JsonEncoder.withIndent('  ').convert({
        'firstName': state.firstName,
        'lastName': state.lastName,
      })}');
      await persistNameUpdate(state.firstName, state.lastName);
      // TODO: Remplacer par updatedFlow.currentStep quand le backend renvoie le flow mis à jour.
      emit(stateForStep(_nameStep.next!));
    } catch (e) {
      emit(RegistrationError(
        message: e.toString(),
        currentStep: state.currentStep,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
      ));
      emit(RegistrationNameInputReady(
        currentStep: _nameStep,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
        isFormValid: true,
      ));
    }
  }

  Future<void> _onBackPressed(
    RegistrationBackPressed event,
    Emitter<RegistrationState> emit,
  ) async {
    final previousStep = state.currentStep.previous;
    if (previousStep == null) return;
    log('[RegistrationBloc] RegistrationBackPressed ← ${state.currentStep}');
    emit(stateForStep(previousStep));
  }

  Future<void> _onNotificationPermissionRequested(
    RegistrationNotificationPermissionRequested event,
    Emitter<RegistrationState> emit,
  ) async {
    await notifyPermissionGranted();
    await _finalizeRegistration(emit);
  }

  Future<void> _onNotificationPermissionSkipped(
    RegistrationNotificationPermissionSkipped event,
    Emitter<RegistrationState> emit,
  ) async {
    await _finalizeRegistration(emit);
  }

  Future<void> _finalizeRegistration(Emitter<RegistrationState> emit) async {
    final result = await completeRegistration();
    switch (result) {
      case Ok():
        emit(RegistrationAuthenticated(
          currentStep: _completeStep,
          email: state.email,
          firstName: state.firstName,
          lastName: state.lastName,
        ));
      case Error(:final error):
        emit(RegistrationError(
          message: error.message,
          currentStep: _completeStep,
          email: state.email,
          firstName: state.firstName,
          lastName: state.lastName,
        ));
        emit(RegistrationNotificationReady(
          currentStep: _completeStep,
          email: state.email,
          firstName: state.firstName,
          lastName: state.lastName,
        ));
    }
  }
}

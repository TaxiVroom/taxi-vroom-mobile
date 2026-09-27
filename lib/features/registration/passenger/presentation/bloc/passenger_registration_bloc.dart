import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:mobile/core/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/core/utils/email_validator.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/complete_passenger_registration_usecase.dart';
import 'package:mobile/features/registration/passenger/domain/usecases/request_notification_permission_usecase.dart';
import 'package:mobile/features/registration/shared/bloc/registration_bloc.dart';
import 'package:mobile/features/registration/shared/bloc/registration_state.dart';
import 'package:mobile/features/registration/shared/domain/usecases/update_registration_flow_usecase.dart';

class PassengerRegistrationBloc extends RegistrationBloc {
  PassengerRegistrationBloc({
    required PassengerRegistrationFlowEntity registrationFlow,
    required UpdateRegistrationFlowUseCase updateRegistrationFlowUseCase,
    required RequestNotificationPermissionUseCase requestNotificationPermissionUseCase,
    required CheckEmailAvailabilityUseCase checkEmailAvailabilityUseCase,
    required CompletePassengerRegistrationUseCase completePassengerRegistrationUseCase,
  })  : _requestNotificationPermissionUseCase =
            requestNotificationPermissionUseCase,
        _completePassengerRegistrationUseCase =
            completePassengerRegistrationUseCase,
        super(
          userId: registrationFlow.userId,
          emailStep: PassengerRegistrationStep.email,
          nameStep: PassengerRegistrationStep.name,
          completeStep: PassengerRegistrationStep.complete,
          updateRegistrationFlowUseCase: updateRegistrationFlowUseCase,
          checkEmailAvailabilityUseCase: checkEmailAvailabilityUseCase,
          // FIXME: Business logic present in the Presentation layer.
          // This orchestration (step routing based on registrationFlow) should be
          // moved to a dedicated UseCase in the Domain layer.
          // To be refactored to comply with Clean Architecture (10 years maintenance).
          initialState: _initialState(registrationFlow),
        );

  final RequestNotificationPermissionUseCase
      _requestNotificationPermissionUseCase;
  final CompletePassengerRegistrationUseCase
      _completePassengerRegistrationUseCase;

  static RegistrationState _initialState(
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
      PassengerRegistrationStep.socialLink => RegistrationSocialLinkReady(
          currentStep: flow.currentStep,
        ),
      PassengerRegistrationStep.email => RegistrationEmailInputReady(
          currentStep: flow.currentStep,
          email: flow.email ?? '',
        ),
      PassengerRegistrationStep.name => RegistrationNameInputReady(
          currentStep: flow.currentStep,
          email: flow.email ?? '',
          firstName: flow.firstName ?? '',
          lastName: flow.lastName ?? '',
        ),
      PassengerRegistrationStep.notifications => RegistrationNotificationReady(
          currentStep: flow.currentStep,
          email: flow.email ?? '',
          firstName: flow.firstName ?? '',
          lastName: flow.lastName ?? '',
        ),
      // Normally never reached: AuthBloc sends a finalized passenger home.
      PassengerRegistrationStep.complete => RegistrationAuthenticated(
          currentStep: flow.currentStep,
          email: flow.email ?? '',
          firstName: flow.firstName ?? '',
          lastName: flow.lastName ?? '',
        ),
    };
  }

  @override
  RegistrationState stateForStep(RegistrationStep step) => switch (step) {
        PassengerRegistrationStep.socialLink => RegistrationSocialLinkReady(
            currentStep: step,
            email: state.email,
            firstName: state.firstName,
            lastName: state.lastName,
          ),
        PassengerRegistrationStep.email => RegistrationEmailInputReady(
            currentStep: step,
            email: state.email,
            firstName: state.firstName,
            lastName: state.lastName,
            isFormatValid: EmailValidator.isValid(state.email),
          ),
        PassengerRegistrationStep.name => RegistrationNameInputReady(
            currentStep: step,
            email: state.email,
            firstName: state.firstName,
            lastName: state.lastName,
            isFormValid:
                state.firstName.isNotEmpty && state.lastName.isNotEmpty,
          ),
        PassengerRegistrationStep.notifications => RegistrationNotificationReady(
            currentStep: step,
            email: state.email,
            firstName: state.firstName,
            lastName: state.lastName,
          ),
        PassengerRegistrationStep.complete => RegistrationAuthenticated(
            currentStep: step,
            email: state.email,
            firstName: state.firstName,
            lastName: state.lastName,
          ),
        _ => throw StateError(
            'Unexpected step for passenger registration: $step',
          ),
      };

  @override
  Future<void> notifyPermissionGranted() =>
      _requestNotificationPermissionUseCase();

  @override
  Future<Result<void>> completeRegistration() =>
      _completePassengerRegistrationUseCase();
}

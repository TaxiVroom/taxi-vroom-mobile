import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/authentication/domain/entities/user_role.dart';
import 'package:mobile/features/authentication/domain/usecases/get_or_create_registration_flow_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/send_otp_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/verify_otp_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SendOtpUseCase sendOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required GetOrCreateRegistrationFlowUseCase getOrCreateRegistrationFlowUseCase,
  })  : _sendOtpUseCase = sendOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _getOrCreateRegistrationFlowUseCase = getOrCreateRegistrationFlowUseCase,
        super(const AuthInitial()) {
    on<AuthPhoneNumberChanged>(_onPhoneNumberChanged);
    on<AuthPhoneNumberSubmitted>(_onPhoneNumberSubmitted);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthOtpResendRequested>(_onOtpResendRequested);
    on<AuthOtpTimerTicked>(_onOtpTimerTicked);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthRoleChosen>(_onRoleChosen);
    on<AuthBackPressed>(_onBackPressed);
    on<AuthRegistrationCompleted>(_onRegistrationCompleted);
  }

  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final GetOrCreateRegistrationFlowUseCase _getOrCreateRegistrationFlowUseCase;

  StreamSubscription<int>? _timerSubscription;

  void _onPhoneNumberChanged(
    AuthPhoneNumberChanged event,
    Emitter<AuthState> emit,
  ) {
    final isValid = event.internationalPhoneNumber
            .replaceAll(RegExp(r'\D'), '')
            .length >=
        AppConstants.phoneMinDigitCount;
    final roleSelectedState = state as AuthRoleSelectedState;
    emit(AuthPhoneNumberInputReady(
      role: roleSelectedState.role,
      phoneNumber: event.internationalPhoneNumber,
      isPhoneValid: isValid,
    ));
  }

  Future<void> _onPhoneNumberSubmitted(
    AuthPhoneNumberSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final roleSelectedState = state as AuthRoleSelectedState;
    emit(AuthPhoneNumberLoading(
      role: roleSelectedState.role,
      phoneNumber: roleSelectedState.phoneNumber,
    ));
    // TODO: Check if there is a package that verifies whether a phone number is valid or not, regardless of the country code.
    try {
      await _sendOtpUseCase(phoneNumber: roleSelectedState.phoneNumber);
      emit(AuthOtpSent(role: roleSelectedState.role, phoneNumber: roleSelectedState.phoneNumber));
      _startOtpResendCountdown(emit: emit);
    } catch (e) {
      emit(AuthError(
        message: e.toString(),
        role: roleSelectedState.role,
        phoneNumber: roleSelectedState.phoneNumber,
      ));
      emit(AuthPhoneNumberInputReady(
        role: roleSelectedState.role,
        phoneNumber: roleSelectedState.phoneNumber,
        isPhoneValid: true,
      ));
    }
  }

  /// Does NOT emit [AuthOtpSent] — the user is already on the OTP screen.
  /// Ticks are handled by [_onOtpTimerTicked].
  void _startOtpResendCountdown({required Emitter<AuthState> emit}) {
    _timerSubscription?.cancel();
    final roleSelectedState = state as AuthRoleSelectedState;
    emit(AuthOtpCountdown(
      role: roleSelectedState.role,
      phoneNumber: roleSelectedState.phoneNumber,
      remainingSeconds: AppConstants.otpCountdownSeconds,
      isResendAvailable: false,
    ));
    _timerSubscription = Stream<int>.periodic(
      const Duration(seconds: 1),
      (tick) => AppConstants.otpCountdownSeconds - tick - 1,
    ).take(AppConstants.otpCountdownSeconds).listen(
      (secondsLeft) => add(AuthOtpTimerTicked(remainingSeconds: secondsLeft)),
    );
  }

  void _onOtpTimerTicked(
    AuthOtpTimerTicked event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthOtpCountdown) {
      final current = state as AuthOtpCountdown;
      emit(current.copyWith(
        remainingSeconds: event.remainingSeconds,
        isResendAvailable: event.remainingSeconds <= 0,
      ));
    }
  }

  // FIXME (And it's the same for all the other functions in the block): Business logic present in the Presentation layer.
  // This orchestration (OTP verification + Backend check) should be
  // moved to a dedicated UseCase in the Domain layer.
  // To be refactored to comply with Clean Architecture (10 years maintenance).
  Future<void> _onOtpSubmitted(
    AuthOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final roleSelectedState = state as AuthRoleSelectedState;
    final role = roleSelectedState.role;
    final phoneNumber = roleSelectedState.phoneNumber;
    _timerSubscription?.cancel();
    emit(AuthOtpVerifying(role: role, phoneNumber: phoneNumber));
    try {
      final user = await _verifyOtpUseCase(
        phoneNumber: event.phoneNumber,
        otp: event.otp,
      );
      final registrationFlow =
          await _getOrCreateRegistrationFlowUseCase(userId: user.id, role: role, phone: phoneNumber);
      // AuthOtpVerified porte la sealed class RegistrationFlowEntity.
      // Le navigator fait un switch exhaustif dessus pour router vers
      // PassengerRegistrationNavigator ou DriverRegistrationNavigator.
      emit(AuthOtpVerified(role: role, registrationFlow: registrationFlow));
    } catch (e) {
      emit(AuthError(message: e.toString(), role: role, phoneNumber: phoneNumber));
      emit(AuthOtpCountdown(
        role: role,
        phoneNumber: phoneNumber,
        remainingSeconds: 0,
        isResendAvailable: true,
      ));
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthGoogleSignInLoading(role: event.role));
    try {
      // TODO: Remplacer par un vrai appel Google Sign-In + getOrCreateRegistrationFlow
      await Future<void>.delayed(const Duration(seconds: 1));
      emit(AuthOtpVerified(
        role: event.role,
        registrationFlow: const PassengerRegistrationFlowEntity(
          userId: 'google-mock-user-id',
          currentStep: PassengerRegistrationStep.email,
        ),
      ));
    } catch (e) {
      emit(AuthError(message: e.toString(), role: event.role));
    }
  }

  Future<void> _onOtpResendRequested(
    AuthOtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    final roleSelectedState = state as AuthRoleSelectedState;
    final role = roleSelectedState.role;
    final phoneNumber = roleSelectedState.phoneNumber;
    // Disable the resend button immediately to give instant visual feedback.
    emit(AuthOtpCountdown(
      role: role,
      phoneNumber: phoneNumber,
      remainingSeconds: 0,
      isResendAvailable: false,
    ));
    try {
      await _sendOtpUseCase(phoneNumber: event.phoneNumber);
      _startOtpResendCountdown(emit: emit);
    } catch (e) {
      emit(AuthError(message: e.toString(), role: role, phoneNumber: phoneNumber));
      emit(AuthOtpCountdown(
        role: role,
        phoneNumber: phoneNumber,
        remainingSeconds: 0,
        isResendAvailable: true,
      ));
    }
  }

  void _onRoleChosen(
    AuthRoleChosen event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthPhoneNumberInputReady(role: event.role));
  }

  void _onBackPressed(
    AuthBackPressed event,
    Emitter<AuthState> emit,
  ) {
    switch (state) {
      case AuthPhoneNumberInputReady() || AuthPhoneNumberLoading():
        emit(const AuthInitial());
      case AuthOtpSent() || AuthOtpCountdown() || AuthOtpVerifying():
        _timerSubscription?.cancel();
        emit(AuthPhoneNumberInputReady(
          role: (state as AuthRoleSelectedState).role,
        ));
      default:
        break;
    }
  }

  void _onRegistrationCompleted(
    AuthRegistrationCompleted event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthAuthenticated(role: (state as AuthRoleSelectedState).role));
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    return super.close();
  }
}

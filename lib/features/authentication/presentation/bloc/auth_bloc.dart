import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/features/authentication/domain/utils/email_validator.dart';
import 'package:mobile/features/authentication/data/models/user_model.dart';
import 'package:mobile/features/authentication/domain/usecases/check_email_availability_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/register_user_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/request_notification_permission_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/send_otp_usecase.dart';
import 'package:mobile/features/authentication/domain/usecases/verify_otp_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SendOtpUseCase sendOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required RegisterUserUseCase registerUserUseCase,
    required RequestNotificationPermissionUseCase requestNotificationPermissionUseCase,
    required CheckEmailAvailabilityUseCase checkEmailAvailabilityUseCase,
  })  : _sendOtpUseCase = sendOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _registerUserUseCase = registerUserUseCase,
        _requestNotificationPermissionUseCase =
            requestNotificationPermissionUseCase,
        _checkEmailAvailabilityUseCase = checkEmailAvailabilityUseCase,
        super(const AuthInitial()) {
    on<AuthPhoneNumberChanged>(_onPhoneNumberChanged);
    on<AuthPhoneNumberSubmitted>(_onPhoneNumberSubmitted);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthOtpResendRequested>(_onOtpResendRequested);
    on<AuthOtpTimerTicked>(_onOtpTimerTicked);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthEmailOptionSelected>(_onEmailOptionSelected);
    on<AuthEmailTyped>(_onEmailTyped);
    on<AuthEmailSubmitted>(_onEmailSubmitted);
    on<AuthNameSubmitted>(_onNameSubmitted);
    on<AuthNameFirstNameTyped>(_onNameFirstNameTyped);
    on<AuthNameLastNameTyped>(_onNameLastNameTyped);
    on<AuthNotificationPermissionRequested>(_onNotificationPermissionRequested);
    on<AuthNotificationPermissionSkipped>(_onNotificationPermissionSkipped);
  }

  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final RequestNotificationPermissionUseCase
      _requestNotificationPermissionUseCase;
  final CheckEmailAvailabilityUseCase _checkEmailAvailabilityUseCase;

  StreamSubscription<int>? _timerSubscription;

  // Données conservées entre les étapes
  String _phoneNumber = '';
  String _email = '';
  String _firstName = '';
  String _lastName = '';

  void _onPhoneNumberChanged(
    AuthPhoneNumberChanged event,
    Emitter<AuthState> emit,
  ) {
    _phoneNumber = event.internationalPhoneNumber;
    final isValid = event.internationalPhoneNumber.replaceAll(RegExp(r'\D'), '').length >= AppConstants.phoneMinDigitCount;
    emit(AuthPhoneNumberInputReady(isPhoneValid: isValid));
  }

  Future<void> _onPhoneNumberSubmitted(
    AuthPhoneNumberSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthPhoneNumberLoading());
    try {
      await _sendOtpUseCase(phoneNumber: _phoneNumber);
      emit(AuthOtpSent(phoneNumber: _phoneNumber));
      _startCountdown(phoneNumber: _phoneNumber, emit: emit);
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(const AuthPhoneNumberInputReady(isPhoneValid: true));
    }
  }

  /// Starts the resend countdown. Does NOT emit [AuthOtpSent] — the user
  /// is already on the OTP screen. Ticks are handled by [_onOtpTimerTicked].
  void _startCountdown({
    required String phoneNumber,
    required Emitter<AuthState> emit,
  }) {
    _timerSubscription?.cancel();
    emit(AuthOtpCountdown(
      phoneNumber: phoneNumber,
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

  Future<void> _onOtpSubmitted(
    AuthOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    _timerSubscription?.cancel();
    emit(AuthOtpVerifying(phoneNumber: event.phoneNumber));
    try {
      final user = await _verifyOtpUseCase(
        phoneNumber: event.phoneNumber,
        otp: event.otp,
      );
      if (user is UserModel && user.isNewUser) {
        emit(AuthNewUserDetected(phoneNumber: event.phoneNumber));
      } else {
        emit(const AuthNotificationReady());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onOtpResendRequested(
    AuthOtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _sendOtpUseCase(phoneNumber: event.phoneNumber);
      _startCountdown(phoneNumber: event.phoneNumber, emit: emit);
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthGoogleSignInLoading());
    try {
      await Future<void>.delayed(const Duration(seconds: 1)); // mock
      emit(const AuthNotificationReady());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _onEmailOptionSelected(
    AuthEmailOptionSelected event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthEmailInputReady(phoneNumber: _phoneNumber));
  }

  void _onEmailTyped(
    AuthEmailTyped event,
    Emitter<AuthState> emit,
  ) {
    _email = event.email.trim();
    final isValid = EmailValidator.isValid(_email);
    final current = state;
    if (current is AuthEmailInputReady) {
      emit(current.copyWith(isFormatValid: isValid));
    } else if (current is AuthEmailTaken) {
      emit(AuthEmailInputReady(phoneNumber: _phoneNumber, isFormatValid: isValid));
    }
  }

  Future<void> _onEmailSubmitted(
    AuthEmailSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthEmailChecking());
    try {
      final isAvailable =
          await _checkEmailAvailabilityUseCase(email: _email);
      if (isAvailable) {
        emit(AuthNameInputReady(phoneNumber: _phoneNumber, email: _email));
      } else {
        emit(AuthEmailTaken(phoneNumber: _phoneNumber));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _onNameFirstNameTyped(
    AuthNameFirstNameTyped event,
    Emitter<AuthState> emit,
  ) {
    _firstName = event.firstName.trim();
    if (state is AuthNameInputReady) {
      emit((state as AuthNameInputReady).copyWith(
        isFormValid: _firstName.isNotEmpty && _lastName.isNotEmpty,
      ));
    }
  }

  void _onNameLastNameTyped(
    AuthNameLastNameTyped event,
    Emitter<AuthState> emit,
  ) {
    _lastName = event.lastName.trim();
    if (state is AuthNameInputReady) {
      emit((state as AuthNameInputReady).copyWith(
        isFormValid: _firstName.isNotEmpty && _lastName.isNotEmpty,
      ));
    }
  }

  Future<void> _onNameSubmitted(
    AuthNameSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthRegistering());
    try {
      await _registerUserUseCase(
        email: _email,
        firstName: _firstName,
        lastName: _lastName,
        phoneNumber: _phoneNumber,
      );
      emit(const AuthNotificationReady());
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(AuthNameInputReady(
        phoneNumber: _phoneNumber,
        email: _email,
        isFormValid: true,
      ));
    }
  }

  Future<void> _onNotificationPermissionRequested(
    AuthNotificationPermissionRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _requestNotificationPermissionUseCase();
    emit(const AuthAuthenticated());
  }

  void _onNotificationPermissionSkipped(
    AuthNotificationPermissionSkipped event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthAuthenticated());
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    return super.close();
  }
}

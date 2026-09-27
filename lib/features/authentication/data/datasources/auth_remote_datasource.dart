import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/features/authentication/data/models/user_model.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/authentication/domain/entities/user_role.dart';
import 'package:mobile/features/registration/driver/data/models/driver_registration_flow_model.dart';
import 'package:mobile/features/registration/passenger/data/models/passenger_registration_flow_model.dart';

// TODO: Violation SRP + ISP (SOLID) — ce datasource mélange deux responsabilités :
//  - Appels Firebase (sendOtp, verifyOtp, linkGoogleAccount)
//  - Appel backend de bootstrap (getOrCreateRegistrationFlow, poignée de main auth→registration)
//  À scinder en FirebaseAuthDataSource et BootstrapDataSource si nécessaire.
abstract class AuthRemoteDataSource {
  Future<void> sendOtp({required String phoneNumber});
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
  });
  Future<UserModel> linkGoogleAccount();
  Future<RegistrationFlowEntity> getOrCreateRegistrationFlow({
    required String userId,
    required UserRole role,
    required String phone,
  });
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._firebaseAuth, this._dio);

  final FirebaseAuth _firebaseAuth;
  final Dio _dio;

  // Stored between sendOtp and verifyOtp calls
  String? _verificationId;

  @override
  Future<void> sendOtp({required String phoneNumber}) async {
    final completer = Completer<void>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        // Auto-verification on some Android devices — OTP retrieved silently.
        if (!completer.isCompleted) completer.complete();
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        if (!completer.isCompleted) completer.complete();
      },
    );

    return completer.future;
  }

  @override
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final verificationId = _verificationId;
    if (verificationId == null) {
      throw FirebaseAuthException(
        code: 'missing-verification-id',
        message: 'sendOtp must be called before verifyOtp.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'null-user',
        message: 'Sign in succeeded but user is null.',
      );
    }

    return UserModel(
      id: firebaseUser.uid,
      phoneNumber: firebaseUser.phoneNumber ?? phoneNumber,
    );
  }

  @override
  Future<UserModel> linkGoogleAccount() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const UserModel(id: 'mock-google-id', phoneNumber: '');
  }

  @override
  Future<RegistrationFlowEntity> getOrCreateRegistrationFlow({
    required String userId,
    required UserRole role,
    required String phone,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/registration-flows/me',
      // Le rôle et le téléphone sont envoyés en query param pour que le backend
      // puisse créer le bon type de flow si l'utilisateur n'en a pas encore.
      queryParameters: {'role': role.name.toUpperCase(), 'phone': phone},
    );
    final json = response.data!;
    return switch (json['role'] as String) {
      'PASSENGER' => PassengerRegistrationFlowModel.fromJson(
        json,
        userId: userId,
      ),
      'DRIVER' => DriverRegistrationFlowModel.fromJson(json, userId: userId),
      final unknownRole => throw UnimplementedError(
        'Unknown registration flow role: $unknownRole',
      ),
    };
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}

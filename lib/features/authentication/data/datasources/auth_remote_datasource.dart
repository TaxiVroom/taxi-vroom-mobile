import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp({required String phoneNumber});
  Future<UserModel> verifyOtp({required String phoneNumber, required String otp});
  Future<UserModel> linkGoogleAccount();
  Future<UserModel> registerWithEmail({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });
  Future<bool> checkEmailAvailability({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

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

    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);

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
      // FIXME: Violation of SRP, What's more, the problem is that yes, his
      //  number is recognized, but it goes straight to the notifications page,
      // when in fact he may not even have entered his name yet.
      isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
    );
  }

  @override
  Future<UserModel> linkGoogleAccount() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const UserModel(
        id: 'mock-google-id', phoneNumber: '', isNewUser: false);
  }

  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return UserModel(
      id: 'mock-email-id',
      phoneNumber: phoneNumber,
      email: email,
      firstName: firstName,
      lastName: lastName,
      isNewUser: false,
    );
  }

  @override
  Future<bool> checkEmailAvailability({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return true;
  }
}

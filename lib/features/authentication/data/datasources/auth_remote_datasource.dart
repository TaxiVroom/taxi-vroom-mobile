import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/features/authentication/data/models/user_model.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_update.dart';

// TODO: Violation SRP + ISP (SOLID) — ce datasource mélange deux responsabilités :
//  - Appels Firebase (sendOtp, verifyOtp, linkGoogleAccount)
//  - Appels backend HTTP (fetchRegistrationFlow, registerWithEmail, checkEmailAvailability)
//  À scinder en FirebaseAuthDataSource et RegistrationFlowDataSource.
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
  Future<RegistrationFlowEntity> getOrCreateRegistrationFlow({required String userId});

  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  });

  Future<void> createPassenger({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  });
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
    );
  }

  @override
  Future<UserModel> linkGoogleAccount() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const UserModel(id: 'mock-google-id', phoneNumber: '');
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
    );
  }

  @override
  Future<bool> checkEmailAvailability({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return true;
  }

  @override
  Future<void> updateRegistrationFlow({
    required String userId,
    required RegistrationFlowUpdate update,
  }) async {
    // We translate the sealed class into JSON: only the fields for the current step
    // are sent, the rest is ignored by the backend (PATCH).
    // FIXME: Add a toJson method on RegistrationFlowUpdate subclasses
    //  so this switch lives in the model, not here.
    // ignore: unused_local_variable
    final body = switch (update) {
      EmailUpdate(:final email) => {'email': email},
      NameUpdate(:final firstName, :final lastName) => {
          'first_name': firstName,
          'last_name': lastName,
        },
    };
    // TODO: PATCH /registration-flows/:userId with body
    throw UnimplementedError('updateRegistrationFlow not yet connected to backend');
  }

  @override
  Future<void> createPassenger({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    // TODO: POST /passengers  { userId, email, firstName, lastName }
    throw UnimplementedError('createPassenger not yet connected to backend');
  }

  @override
  Future<RegistrationFlowEntity> getOrCreateRegistrationFlow({required String userId}) async {
    // TODO: GET /registration-flows/:userId
    // Le JSON doit contenir un champ 'role' ('passenger' | 'driver') pour construire
    // le bon sous-type (PassengerRegistrationFlowModel ou DriverRegistrationFlowModel).
    // Le backend crée la registration_flow si elle n'existe pas encore.
    throw UnimplementedError('getOrCreateRegistrationFlow not yet connected to backend');
  }
}

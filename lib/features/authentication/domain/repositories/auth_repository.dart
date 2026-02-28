import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_update.dart';
import 'package:mobile/features/authentication/domain/entities/user_entity.dart';

// TODO: Interface instead of abstract class
// TODO: Violation SRP + ISP (SOLID) — ce repository mélange deux responsabilités :
//  - Authentification Firebase (sendOtp, verifyOtp, linkGoogleAccount)
//  - Inscription backend (fetchRegistrationFlow, registerWithEmail, checkEmailAvailability)
//  À scinder en AuthRepository et RegistrationFlowRepository.
abstract class AuthRepository {
  Future<void> sendOtp({required String phoneNumber});

  Future<UserEntity> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  Future<UserEntity> linkGoogleAccount();

  Future<UserEntity> registerWithEmail({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });

  // Please note that the email address may already be taken by the user themselves, in which case you must indicate that the email address is valid.
  // You will need to search for the email address in the Register table and the User table, as someone else may be registering with the same email address.
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

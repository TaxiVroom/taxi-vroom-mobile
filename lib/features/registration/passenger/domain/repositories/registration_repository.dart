import 'package:mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:mobile/features/registration/passenger/domain/entities/registration_flow_update.dart';

abstract class RegistrationRepository {
  Future<UserEntity> registerWithEmail({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });

  // Please note that the email address may already be taken by the user themselves, in which case you must indicate that the email address is valid.
  // You will need to search for the email address in the Register table and the User table, as someone else may be registering with the same email address.
  Future<bool> checkEmailAvailability({required String email});

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

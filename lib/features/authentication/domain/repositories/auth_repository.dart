import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/authentication/domain/entities/registration_flow_entity.dart';
import 'package:mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:mobile/features/authentication/domain/entities/user_role.dart';

abstract class AuthRepository {
  Future<void> sendOtp({required String phoneNumber});

  Future<UserEntity> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  Future<UserEntity> linkGoogleAccount();

  Future<RegistrationFlowEntity> getOrCreateRegistrationFlow({
    required String userId,
    required UserRole role,
    required String phone,
  });

  // Null when nobody is signed in, or when it cannot be told.
  Future<UserRole?> findSessionRole();

  Future<Result<void>> signOut();
}

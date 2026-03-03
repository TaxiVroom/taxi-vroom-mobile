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

  Future<RegistrationFlowEntity> getOrCreateRegistrationFlow({required String userId, required UserRole role, required String phone});
}

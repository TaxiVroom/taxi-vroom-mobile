import 'package:mobile/features/authentication/domain/entities/user_entity.dart';

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

  Future<bool> checkEmailAvailability({required String email});
}
